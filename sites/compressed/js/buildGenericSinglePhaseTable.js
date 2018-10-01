// ['P [MPa]','t [℃]','v [cm³/g]','h [kJ/kg]','s [kJ/kg-K]']
function buildGenericSinglePhaseTable () {
   var ptvuhs;				// the entire 2-dim singlephase data array
   var ptvuhsHTML;		// 2d singlephase array in html
   var tvuhs;				// array of 2d arrays tvuhs. tvuhs[n] corresponds with p[n]
   var p;					// 1d array of pressures from the ptvuhs table
   var tvuhs_tmp;			// temporary variable for building tvuhs 2d arrays
   var i, r, index_p, index_t, index_tvuhs;		// counters
   var tvuhsMaxLength;  			// length of longest tvuhs array
   var theadRow1, theadRow2;		// HTML text

	// the source data, formatted as ptvuhs = [p,[t,v,u,h,s]]    [IAPWS95 tables]
ptvuhs =
[[2.5,20,1.0006,83.8,86.3,0.2961],[2.5,40,1.0067,167.25,169.77,0.5715],[2.5,80,1.028,334.29,336.86,1.0737],[2.5,100,1.0423,418.24,420.85,1.305],[2.5,140,1.0784,587.82,590.52,1.7369],[2.5,180,1.1261,761.16,763.97,2.1375],[2.5,200,1.1555,849.9,852.8,2.3294],[2.5,220,1.1898,940.7,943.7,2.5174],[2.5,223.99,1.1973,959.1,962.1,2.5546],[5,20,0.9995,83.65,88.65,0.2956],[5,40,1.0056,166.95,171.97,0.5705],[5,80,1.0268,333.72,338.85,1.072],[5,100,1.041,417.52,422.72,1.303],[5,140,1.0768,586.76,592.15,1.7343],[5,180,1.124,759.63,765.25,2.1341],[5,200,1.153,848.1,853.9,2.3255],[5,220,1.1866,938.4,944.4,2.5128],[5,263.99,1.2859,1147.8,1154.2,2.9202],[7.5,20,0.9984,83.5,90.99,0.295],[7.5,40,1.0045,166.64,174.18,0.5696],[7.5,80,1.0256,333.15,340.84,1.0704],[7.5,100,1.0397,416.81,424.62,1.3011],[7.5,140,1.0752,585.72,593.78,1.7317],[7.5,180,1.1219,758.13,766.55,2.1308],[7.5,220,1.1835,936.2,945.1,2.5083],[7.5,260,1.2696,1124.4,1134,2.8763],[7.5,290.59,1.3677,1282,1292.2,3.1649],[10,20,0.9972,83.36,93.33,0.2945],[10,40,1.0034,166.35,176.38,0.5686],[10,80,1.0245,332.59,342.83,1.0688],[10,100,1.0385,416.12,426.5,1.2992],[10,140,1.0737,584.68,595.42,1.7292],[10,180,1.1199,756.65,767.84,2.1275],[10,220,1.1805,934.1,945.9,2.5039],[10,260,1.2645,1121.1,1133.7,2.8699],[10,311.06,1.4524,1393,1407.6,3.3596],[15,20,0.995,83.06,97.99,0.2934],[15,40,1.0013,165.76,180.78,0.5666],[15,80,1.0222,331.48,346.81,1.0656],[15,100,1.0361,414.74,430.28,1.2955],[15,140,1.0707,582.66,598.72,1.7242],[15,180,1.1159,753.76,770.5,2.121],[15,220,1.1748,929.9,947.5,2.4953],[15,260,1.255,1114.6,1133.4,2.8576],[15,300,1.377,1316.6,1337.3,3.226],[15,342.24,1.6581,1585.6,1610.5,3.6848],[20,20,0.9928,82.77,102.62,0.2923],[20,40,0.9992,165.17,185.16,0.5646],[20,80,1.0199,330.4,350.8,1.0624],[20,100,1.0337,413.39,434.06,1.2917],[20,140,1.0678,580.69,602.04,1.7193],[20,180,1.112,750.95,773.2,2.1147],[20,220,1.1693,925.9,949.3,2.487],[20,260,1.2462,1108.6,1133.5,2.8459],[20,300,1.3596,1306.1,1333.3,3.2071],[20,365.81,2.036,1785.6,1826.3,4.0139],[25,20,0.9907,82.47,107.24,0.2911],[25,40,0.9971,164.6,189.52,0.5626],[25,100,1.0313,412.08,437.85,1.2881],[25,200,1.1344,834.5,862.8,2.2961],[25,300,1.3442,1296.6,1330.2,3.19],[30,20,0.9886,82.17,111.84,0.2899],[30,40,0.9951,164.04,193.89,0.5607],[30,100,1.029,410.78,441.66,1.2844],[30,200,1.1302,831.4,865.3,2.2893],[30,300,1.3304,1287.9,1327.8,3.1741]];
// console.log('ptvuhs length: ' + ptvuhs.length);

   // build p, tvuhs arrays. lets us reference p and corresponding tvuhs more easily
   p = [ptvuhs[0][0]];								// initialize with pressure ptvuhs first row
   tvuhs_tmp = [ptvuhs[0].slice(1)];			// initialize with first tvuhs vector belonging to the first pressure

// console.log('ptvuhs[0].slice(1):'+tvuhs_tmp );

   index_p = 0;
   tvuhs = [0];

   for ( r = 1; r < ptvuhs.length; r++) {
   	if ( p.includes(ptvuhs[r][0]) ) {				// ok. if true, we've seen this pressure before,
         tvuhs_tmp.push(ptvuhs[r].slice(1));			// so add a row to current tvuhs array
      }
      else {
// console.log ('tvuhs_tmp: ' + tvuhs_tmp);
         tvuhs[index_p] = tvuhs_tmp;					// assign tvuhs to current pressure
         index_p++;											// increment index_p on p vector
         p.push(ptvuhs[r][0]);							// add new p to pressure vector
         tvuhs_tmp =[ ptvuhs[r].slice(1) ];			// initialize tvhs for new p
      }
   }
   tvuhs[index_p] = tvuhs_tmp;		// assign last tvhs and
                                    // the data table is built!!!

// console.log('tvuhs[10]:'+tvuhs[10]+'  tvuhs[10].length:'+tvuhs[10].length+'   p[10]:'+p[10]);

   // now we build the entire html table ptvuhsHTML (minified) in text for use in an innerHTML call
   // build the top header row and determine longest tvuhs array
   tvuhsMaxLength = 0;
   ptvuhsHTML = '<thead>';
   theadRow1 = '<tr>';
   theadRow2 = '<tr>';
   for (index_p = 0; index_p < p.length; index_p++) {
      theadRow1 += '<th colspan="' + (ptvuhs[0].length - 1) + '">' + p[index_p] + ' MPa</th>';
      theadRow2 += '<th>T <span class="uNits">&#x00b0;C</span></th>'
            + '<th>v <span class="uNits">cm<sup>3</sup>/kg</span></th>'
            + '<th>u <span class="uNits">kJ/kg</span></th>'
            + '<th>h <span class="uNits">kJ/kg</span></th>'
            + '<th>s <span class="uNits">kJ/kg-K</span></th>';
      // while we're here, determine the length of the longest temperature vector
      tvuhsMaxLength = Math.max(tvuhsMaxLength,tvuhs[index_p].length);
   };	// end for index_p

   theadRow1 += '</tr>';	// close out the row
   theadRow2 += '</tr>';	// close out the row

// console.log('tvuhsMaxLength: '+tvuhsMaxLength);
// console.log('p.length: '+p.length);
// console.log('ptvuhs[0].length: '+ptvuhs[0].length);
   // console.log('temps:'+tvuhs)

   ptvuhsHTML += theadRow1 + theadRow2 + '</thead>';		// add to table declaration with thead closeout
   // thead section is now complete

   // now build the tbody rows
   ptvuhsHTML += '<tbody>';
   for (index_t = 0; index_t < tvuhsMaxLength; index_t++) {
      tvuhs_tmp = '<tr>';                   // we're building a row, yall
      for (index_p = 0; index_p < p.length; index_p++) {
         if (index_t < tvuhs[index_p].length) {
            tvuhs_tmp += '<th>'+tvuhs[index_p][index_t][0]+'</th>'; // insert temperature head cell
            for ( index_tvuhs = 1; index_tvuhs < tvuhs[index_p][index_t].length; index_tvuhs++) {   // traverse the row to capture vuhs
            	tvuhs_tmp += '<td>' + tvuhs[index_p][index_t][index_tvuhs] + '</td>';         // add the <td> cells
// console.log('t:'+index_t+' p:'+index_p+'   tvuhs:'+index_tvuhs+' tvuhs[index_p][index_t][index_tvuhs]:'+tvuhs[index_p][index_t][index_tvuhs]);
            };
         }
         else {									// no more rows for this pressure. fill in the table with a row of empty cells for consistency in the table.
            tvuhs_tmp += '<th></th>' + '<td></td>'.repeat(tvuhs[index_p][0].length - 1);
         }
      }; // end for index_p
      ptvuhsHTML += tvuhs_tmp + '</tr>';	// end the sub row
   }; // end for index_t
   ptvuhsHTML += '</tbody>';  // end building the table innards

// console.log(ptvuhsHTML)
// write a nifty function call to use ptvuhsHTML withouth having to assemble it

const ptvuhsHTMLjs = 'function ptvuhsHTMLjs() {return \''+ptvuhsHTML+'\';}' ;

download('ptvuhsHTML.js', ptvuhsHTMLjs);
console.log('tvuhs:'+tvuhs);

   return ptvuhsHTML;
}


function download(filename, text) {
    var pom = document.createElement('a');
    pom.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(text));
    pom.setAttribute('download', filename);

    if (document.createEvent) {
        var event = document.createEvent('MouseEvents');
        event.initEvent('click', true, true);
        pom.dispatchEvent(event);
    }
    else {
        pom.click();
    }
}
