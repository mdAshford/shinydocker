# ψᵟ
#





# ψᵟ
#
#
# Based on base-notebook from Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
#
FROM jupyter/scipy-notebook

LABEL maintainer="mdAshford"

USER root

# R pre-requisites
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    fonts-dejavu \
    tzdata \
    gfortran \
    tree \
    gcc \
    lsb-core \
    gnupg \
 && rm -rf /var/lib/apt/lists/*


# _____ julia main _____________________________________________
# Julia dependencies
# install Julia packages in /opt/julia instead of $HOME
# user root
ENV JULIA_DEPOT_PATH=/opt/julia
ENV JULIA_PKGDIR=/opt/julia
ENV JULIA_VERSION=1.0.3

#
RUN mkdir /opt/julia-${JULIA_VERSION} && \
    cd /tmp && \
    wget -q https://julialang-s3.julialang.org/bin/linux/x64/`echo ${JULIA_VERSION} | cut -d. -f 1,2`/julia-${JULIA_VERSION}-linux-x86_64.tar.gz && \
    echo "362ba867d2df5d4a64f824e103f19cffc3b61cf9d5a9066c657f1c5b73c87117 *julia-${JULIA_VERSION}-linux-x86_64.tar.gz" | sha256sum -c - && \
    tar xzf julia-${JULIA_VERSION}-linux-x86_64.tar.gz -C /opt/julia-${JULIA_VERSION} --strip-components=1 && \
    rm /tmp/julia-${JULIA_VERSION}-linux-x86_64.tar.gz

RUN ln -fs /opt/julia-*/bin/julia /usr/local/bin/julia

# Show Julia where conda libraries are \
RUN mkdir /etc/julia  \
 && echo "push!(Libdl.DL_LOAD_PATH, \"$CONDA_DIR/lib\")" >> /etc/julia/juliarc.jl  \
# Create JULIA_PKGDIR \
 && mkdir $JULIA_PKGDIR  \
 && chown $NB_USER $JULIA_PKGDIR  \
 && fix-permissions $JULIA_PKGDIR

# _____ OpenModelica and OMPython main _________________________
# from Dockerfile at https://github.com/OpenModelica/jupyter-openmodelica
# user root
RUN for deb in deb deb-src; do echo "$deb http://build.openmodelica.org/apt `lsb_release -cs` nightly"; done | tee /etc/apt/sources.list.d/openmodelica.list
RUN wget -q http://build.openmodelica.org/apt/openmodelica.asc -O- | apt-key add -
# To verify that your key is installed correctly
RUN apt-key fingerprint
# RUN apt update \
#  && apt install -y openmodelica

# Update index (again) and intsall full openmodelica
RUN apt-get update && apt-get install -y openmodelica omlib-modelica-3.2.2
# RUN apt-get install -y omc omlib-modelica-3.2.2
# RUN apt-get install -y omc omlib-*

# Install Python components
# RUN apt-get install -y python-pip python-dev build-essential
RUN apt-get install -y git

#### no need for yhis step. we already did it
# # Install Jupyter notebook, always upgrade pip
# RUN pip install --upgrade pip
# RUN pip install jupyter jupyterlab

# _____ Octave _________________________________________________
# user root
RUN apt-get update && apt-get install -y octave octave-dataframe

## _____ r _____________________________________________________
USER $NB_UID

# R packages including IRKernel which gets installed globally.
RUN conda install --quiet --yes \
    # 'rpy2=2.9*' \
    # 'r-base=3.5.1' \
    # 'r-irkernel=0.8*' \
    # 'r-plyr=1.8*' \
    # 'r-devtools=1.13*' \
    # 'r-tidyverse=1.2*' \
    # 'r-shiny=1.2*' \
    # 'r-rmarkdown=1.11*' \
    # 'r-forecast=8.2*' \
    # 'r-rsqlite=2.1*' \
    # 'r-reshape2=1.4*' \
    # 'r-nycflights13=1.0*' \
    # 'r-caret=6.0*' \
    # 'r-rcurl=1.95*' \
    # 'r-crayon=1.3*' \
    # 'r-randomforest=4.6*' \
    # 'r-htmltools=0.3*' \
    # 'r-sparklyr=0.9*' \
    # 'r-htmlwidgets=1.2*' \
    # 'r-hexbin=1.27*' \
    'r-essentials' \
    'r-feather' \
    'feather-format'

RUN conda clean -tipsy \
 && fix-permissions $CONDA_DIR \
 && fix-permissions /home/$NB_USER


# _____ julia packages _________________________________________

# Add Julia packages. Only add HDF5 if this is not a test-only build since
# it takes roughly half the entire build time of all of the images on Travis
# to add this one package and often causes Travis to timeout.
#
# Install IJulia as jovyan and then move the kernelspec out
# to the system share location. Avoids problems with runtime UID change not
# taking effect properly on the .local folder in the jovyan home dir.

RUN julia -e 'import Pkg; Pkg.update()'  \
 # && julia -e 'import Pkg; Pkg.add("HDF5")')  \
 && julia -e 'import Pkg; Pkg.add("Gadfly")'  \
 && julia -e 'import Pkg; Pkg.add("RDatasets")'  \
 && julia -e 'import Pkg; Pkg.add("ZMQ")'  \
 && julia -e 'import Pkg; Pkg.add("Compat")'  \
 && julia -e 'import Pkg; Pkg.add("DataStructures")' \
 && julia -e 'import Pkg; Pkg.add("DataFrames")' \
 && julia -e 'import Pkg; Pkg.add("LightXML")' \
 && julia -e 'import Pkg; Pkg.add("Unitful")' \
 && julia -e 'import Pkg; Pkg.add("CSV")' \
 && julia -e 'import Pkg; Pkg.add("Random")'

run julia -e 'import Pkg; Pkg.clone("https://github.com/OpenModelica/OMJulia.jl"); Pkg.resolve(); Pkg.update(); using OMJulia'  \
 && julia -e 'import Pkg; Pkg.add("IJulia")' \
 #  Precompile Julia packages \
 && julia -e 'using IJulia' \
 # move ker&&npec out of home \
 && mv $HOME/.local/share/jupyter/kernels/julia* $CONDA_DIR/share/jupyter/kernels/  \
 && chmod -R go+rx $CONDA_DIR/share/jupyter  \
 && rm -rf $HOME/.local  \
 && fix-permissions $JULIA_PKGDIR $CONDA_DIR/share/jupyter

# _____ install kernels, move to $CONDA_DIR/share/jupyter ______
# Do this as user
user $NB_UID

# OMPython and jupyter-openmodelica
run pip install -U git+git://github.com/OpenModelica/OMPython.git \
 && pip install -U git+git://github.com/OpenModelica/jupyter-openmodelica.git

# SoS
# https://vatlab.github.io/sos-docs/running.html#Local-installation     \
run pip install -U sos \
 && pip install -U sos-notebook \
 && python -m sos_notebook.install \
 \
# Bash
# https://github.com/takluyver/bash_kernel
 && pip install -U bash_kernel \
 && python -m bash_kernel.install \
 \
# Markdown
# https://github.com/vatlab/markdown-kernel
 && pip install markdown-kernel \
 && python -m markdown_kernel.install \
 \
 # Octave
 # https://github.com/Calysto/octave_kernel
 && pip install octave_kernel \
 \
# move kernels to /opt/conda, clean up, fix permissions
 && mv $HOME/.local/share/jupyter/kernels/* $CONDA_DIR/share/jupyter/kernels/  \
 && chmod -R go+rx $CONDA_DIR/share/jupyter  \
 && rm -rf $HOME/.local/share/jupyter/kernels  \
 && fix-permissions $CONDA_DIR/share/jupyter

# copy example files to $HOME/work/examples
user root
copy ./notebooks  $HOME/work/examples/
run chown $NB_USER $HOME/work/examples \
 && fix-permissions $HOME

USER ${NB_UID}

# _____ wrap up and go home ____________________________________
# env JUPYTER_ENABLE_LAB=TRUE
env USER=$NB_USER
# workdir /user/jovyan/work
workdir $HOME/work








#
# Based on base-notebook from Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
#
# FROM jupyter/datascience-notebook
#
# LABEL maintainer="mdAshford"
#
# # https://mybinder.org/v2/gh/BENGAL-TIGER/YOUcanDoThermodynamics/shinydocker
#
#
# USER ${NB_UID}
#
# # _____ wrap up and go home ____________________________________
# # env JUPYTER_ENABLE_LAB=TRUE
# env USER=$NB_USER
# # workdir /user/jovyan/work
# workdir $HOME/work
