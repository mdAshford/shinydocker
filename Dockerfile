


FROM jupyter/datascience-notebook


Based on base-notebook from Jupyter Development Team.
Distributed under the terms of the Modified BSD License.


LABEL maintainer="mdAshford"

# https://mybinder.org/v2/gh/BENGAL-TIGER/YOUcanDoThermodynamics/shinydocker


USER ${NB_UID}

# _____ wrap up and go home ____________________________________
# env JUPYTER_ENABLE_LAB=TRUE
env USER=$NB_USER
# workdir /user/jovyan/work
workdir $HOME/work
