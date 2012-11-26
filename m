Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 7B6096B0062
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 08:33:52 -0500 (EST)
Date: Mon, 26 Nov 2012 13:33:44 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Comparison between three trees (was: Latest numa/core release,
 v17)
Message-ID: <20121126133344.GJ8218@suse.de>
References: <1353624594-1118-1-git-send-email-mingo@kernel.org>
 <20121123173205.GZ8218@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121123173205.GZ8218@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Fri, Nov 23, 2012 at 05:32:05PM +0000, Mel Gorman wrote:
> SPECJBB: Single JVMs (one per node, 4 nodes), THP is disabled
> 
>                         3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0
>                rc6-stats-v5r1 rc6-numacore-20121123rc6-autonuma-v28fastr4   rc6-thpmigrate-v5r1    rc6-adaptscan-v5r1   rc6-delaystart-v5r4
> TPut 1      20890.00 (  0.00%)     18720.00 (-10.39%)     21127.00 (  1.13%)     20376.00 ( -2.46%)     20806.00 ( -0.40%)     20698.00 ( -0.92%)
> TPut 2      48259.00 (  0.00%)     38121.00 (-21.01%)     47920.00 ( -0.70%)     47085.00 ( -2.43%)     48594.00 (  0.69%)     48094.00 ( -0.34%)
> TPut 3      73203.00 (  0.00%)     60057.00 (-17.96%)     73630.00 (  0.58%)     70241.00 ( -4.05%)     73418.00 (  0.29%)     74016.00 (  1.11%)
> TPut 4      98694.00 (  0.00%)     73669.00 (-25.36%)     98929.00 (  0.24%)     96721.00 ( -2.00%)     96797.00 ( -1.92%)     97930.00 ( -0.77%)
> TPut 5     122563.00 (  0.00%)     98786.00 (-19.40%)    118969.00 ( -2.93%)    118045.00 ( -3.69%)    121553.00 ( -0.82%)    122781.00 (  0.18%)
> TPut 6     144095.00 (  0.00%)    114485.00 (-20.55%)    145328.00 (  0.86%)    141713.00 ( -1.65%)    142589.00 ( -1.05%)    143771.00 ( -0.22%)
> TPut 7     166457.00 (  0.00%)    112416.00 (-32.47%)    163503.00 ( -1.77%)    166971.00 (  0.31%)    166788.00 (  0.20%)    165188.00 ( -0.76%)
> TPut 8     191067.00 (  0.00%)    122996.00 (-35.63%)    189477.00 ( -0.83%)    183090.00 ( -4.17%)    187710.00 ( -1.76%)    192157.00 (  0.57%)
> TPut 9     210634.00 (  0.00%)    141200.00 (-32.96%)    209639.00 ( -0.47%)    207968.00 ( -1.27%)    215216.00 (  2.18%)    214222.00 (  1.70%)
> TPut 10    234121.00 (  0.00%)    129508.00 (-44.68%)    231221.00 ( -1.24%)    221553.00 ( -5.37%)    219998.00 ( -6.03%)    227193.00 ( -2.96%)
> TPut 11    257885.00 (  0.00%)    131232.00 (-49.11%)    256568.00 ( -0.51%)    252734.00 ( -2.00%)    258433.00 (  0.21%)    260534.00 (  1.03%)
> TPut 12    271751.00 (  0.00%)    154763.00 (-43.05%)    277319.00 (  2.05%)    277154.00 (  1.99%)    265747.00 ( -2.21%)    262285.00 ( -3.48%)
> TPut 13    297457.00 (  0.00%)    119716.00 (-59.75%)    296068.00 ( -0.47%)    289716.00 ( -2.60%)    276527.00 ( -7.04%)    293199.00 ( -1.43%)
> TPut 14    319074.00 (  0.00%)    129730.00 (-59.34%)    311604.00 ( -2.34%)    308798.00 ( -3.22%)    316807.00 ( -0.71%)    275748.00 (-13.58%)
> TPut 15    337859.00 (  0.00%)    177494.00 (-47.47%)    329288.00 ( -2.54%)    300463.00 (-11.07%)    305116.00 ( -9.69%)    287814.00 (-14.81%)
> TPut 16    356396.00 (  0.00%)    145173.00 (-59.27%)    355616.00 ( -0.22%)    342598.00 ( -3.87%)    364077.00 (  2.16%)    339649.00 ( -4.70%)
> TPut 17    373925.00 (  0.00%)    176956.00 (-52.68%)    368589.00 ( -1.43%)    360917.00 ( -3.48%)    366043.00 ( -2.11%)    345586.00 ( -7.58%)
> TPut 18    388373.00 (  0.00%)    150100.00 (-61.35%)    372873.00 ( -3.99%)    389062.00 (  0.18%)    386779.00 ( -0.41%)    370871.00 ( -4.51%)
> 
> balancenuma suffered here. It is very likely that it was not able to handle
> faults at a PMD level due to the lack of THP and I would expect that the
> pages within a PMD boundary are not on the same node so pmd_numa is not
> set. This results in its worst case of always having to deal with PTE
> faults. Further, it must be migrating many or almost all of these because
> the adaptscan patch made no difference. This is a worst-case scenario for
> balancenuma. The scan rates later will indicate if that was the case.
> 

This worst-case for balancenuma can be hit with a hammer to some extent
(patch below) but the results are too variable to be considered useful. The
headline figures say that balancenuma comes back in line with mainline so
it's not regressing but the devil is in the details. It regresses less
but balancenumas worst-case scenario still hurts. I'm not including the
patch in the tree because the right answer is to rebase a scheduling and
placement policy on top that results in fewer migrations.

However, for reference here is how the hammer affects the results for a
single JVM with THP disabled. adaptalways-v6r12 is the hammer.

SPECJBB BOPS
                        3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0
               rc6-stats-v5r1 rc6-numacore-20121123rc6-autonuma-v28fastr4  rc6-thpmigrate-v6r10 rc6-adaptalways-v6r12
TPut 1      20507.00 (  0.00%)     16702.00 (-18.55%)     19496.00 ( -4.93%)     19831.00 ( -3.30%)     20539.00 (  0.16%)
TPut 2      48723.00 (  0.00%)     36714.00 (-24.65%)     49452.00 (  1.50%)     45973.00 ( -5.64%)     47664.00 ( -2.17%)
TPut 3      72618.00 (  0.00%)     59086.00 (-18.63%)     69728.00 ( -3.98%)     71996.00 ( -0.86%)     71917.00 ( -0.97%)
TPut 4      98383.00 (  0.00%)     76940.00 (-21.80%)     98216.00 ( -0.17%)     95339.00 ( -3.09%)     96118.00 ( -2.30%)
TPut 5     122240.00 (  0.00%)     95981.00 (-21.48%)    119822.00 ( -1.98%)    117487.00 ( -3.89%)    121080.00 ( -0.95%)
TPut 6     144010.00 (  0.00%)    100095.00 (-30.49%)    141127.00 ( -2.00%)    143931.00 ( -0.05%)    141666.00 ( -1.63%)
TPut 7     164690.00 (  0.00%)    119577.00 (-27.39%)    159922.00 ( -2.90%)    164073.00 ( -0.37%)    163861.00 ( -0.50%)
TPut 8     190702.00 (  0.00%)    125183.00 (-34.36%)    189187.00 ( -0.79%)    180400.00 ( -5.40%)    187520.00 ( -1.67%)
TPut 9     209898.00 (  0.00%)    137179.00 (-34.64%)    160205.00 (-23.67%)    206052.00 ( -1.83%)    214639.00 (  2.26%)
TPut 10    234064.00 (  0.00%)    140225.00 (-40.09%)    220768.00 ( -5.68%)    218224.00 ( -6.77%)    224924.00 ( -3.90%)
TPut 11    252408.00 (  0.00%)    134453.00 (-46.73%)    250953.00 ( -0.58%)    248507.00 ( -1.55%)    247219.00 ( -2.06%)
TPut 12    278689.00 (  0.00%)    140355.00 (-49.64%)    271815.00 ( -2.47%)    255907.00 ( -8.17%)    266701.00 ( -4.30%)
TPut 13    298940.00 (  0.00%)    153780.00 (-48.56%)    190433.00 (-36.30%)    289418.00 ( -3.19%)    269335.00 ( -9.90%)
TPut 14    315971.00 (  0.00%)    126929.00 (-59.83%)    309899.00 ( -1.92%)    283315.00 (-10.34%)    308350.00 ( -2.41%)
TPut 15    340446.00 (  0.00%)    132710.00 (-61.02%)    290484.00 (-14.68%)    327168.00 ( -3.90%)    342031.00 (  0.47%)
TPut 16    362010.00 (  0.00%)    156255.00 (-56.84%)    347844.00 ( -3.91%)    311160.00 (-14.05%)    360196.00 ( -0.50%)
TPut 17    376476.00 (  0.00%)     95441.00 (-74.65%)    333508.00 (-11.41%)    366629.00 ( -2.62%)    341397.00 ( -9.32%)
TPut 18    399230.00 (  0.00%)    132993.00 (-66.69%)    374946.00 ( -6.08%)    358280.00 (-10.26%)    324370.00 (-18.75%)
TPut 19    414300.00 (  0.00%)    129194.00 (-68.82%)    392675.00 ( -5.22%)    363700.00 (-12.21%)    368777.00 (-10.99%)
TPut 20    429780.00 (  0.00%)     90068.00 (-79.04%)    241891.00 (-43.72%)    413210.00 ( -3.86%)    351444.00 (-18.23%)
TPut 21    439977.00 (  0.00%)    136793.00 (-68.91%)    412629.00 ( -6.22%)    398914.00 ( -9.33%)    442260.00 (  0.52%)
TPut 22    459593.00 (  0.00%)    134292.00 (-70.78%)    426511.00 ( -7.20%)    414652.00 ( -9.78%)    422916.00 ( -7.98%)
TPut 23    473600.00 (  0.00%)    137794.00 (-70.90%)    436081.00 ( -7.92%)    421456.00 (-11.01%)    359619.00 (-24.07%)
TPut 24    483442.00 (  0.00%)    139342.00 (-71.18%)    390536.00 (-19.22%)    453552.00 ( -6.18%)    486759.00 (  0.69%)
TPut 25    484584.00 (  0.00%)    144745.00 (-70.13%)    430863.00 (-11.09%)    397971.00 (-17.87%)    396648.00 (-18.15%)
TPut 26    483041.00 (  0.00%)    145326.00 (-69.91%)    333960.00 (-30.86%)    454575.00 ( -5.89%)    472979.00 ( -2.08%)
TPut 27    480788.00 (  0.00%)    145395.00 (-69.76%)    402433.00 (-16.30%)    415528.00 (-13.57%)    418540.00 (-12.95%)
TPut 28    470141.00 (  0.00%)    146261.00 (-68.89%)    385008.00 (-18.11%)    445938.00 ( -5.15%)    455615.00 ( -3.09%)
TPut 29    476984.00 (  0.00%)    147988.00 (-68.97%)    379719.00 (-20.39%)    395984.00 (-16.98%)    479828.00 (  0.60%)
TPut 30    471709.00 (  0.00%)    148658.00 (-68.49%)    417249.00 (-11.55%)    424000.00 (-10.11%)    435163.00 ( -7.75%)
TPut 31    470451.00 (  0.00%)    147949.00 (-68.55%)    408792.00 (-13.11%)    384502.00 (-18.27%)    415069.00 (-11.77%)
TPut 32    468377.00 (  0.00%)    158685.00 (-66.12%)    414694.00 (-11.46%)    405441.00 (-13.44%)    468585.00 (  0.04%)
TPut 33    463536.00 (  0.00%)    159097.00 (-65.68%)    412259.00 (-11.06%)    399323.00 (-13.85%)    455622.00 ( -1.71%)
TPut 34    457678.00 (  0.00%)    153025.00 (-66.56%)    408133.00 (-10.83%)    402190.00 (-12.12%)    432962.00 ( -5.40%)
TPut 35    448181.00 (  0.00%)    154037.00 (-65.63%)    405535.00 ( -9.52%)    422016.00 ( -5.84%)    452914.00 (  1.06%)
TPut 36    450490.00 (  0.00%)    149057.00 (-66.91%)    407218.00 ( -9.61%)    381320.00 (-15.35%)    427438.00 ( -5.12%)
TPut 37    435425.00 (  0.00%)    153996.00 (-64.63%)    400370.00 ( -8.05%)    403088.00 ( -7.43%)    381348.00 (-12.42%)
TPut 38    434985.00 (  0.00%)    158683.00 (-63.52%)    408266.00 ( -6.14%)    406860.00 ( -6.47%)    404181.00 ( -7.08%)
TPut 39    425064.00 (  0.00%)    160263.00 (-62.30%)    397737.00 ( -6.43%)    385657.00 ( -9.27%)    425414.00 (  0.08%)
TPut 40    428366.00 (  0.00%)    161150.00 (-62.38%)    383404.00 (-10.50%)    405984.00 ( -5.22%)    444815.00 (  3.84%)
TPut 41    417072.00 (  0.00%)    155817.00 (-62.64%)    394627.00 ( -5.38%)    398389.00 ( -4.48%)    391735.00 ( -6.07%)
TPut 42    398350.00 (  0.00%)    156774.00 (-60.64%)    388583.00 ( -2.45%)    329310.00 (-17.33%)    430361.00 (  8.04%)
TPut 43    405526.00 (  0.00%)    162938.00 (-59.82%)    371761.00 ( -8.33%)    396379.00 ( -2.26%)    397849.00 ( -1.89%)
TPut 44    400696.00 (  0.00%)    167164.00 (-58.28%)    372067.00 ( -7.14%)    373746.00 ( -6.73%)    388050.00 ( -3.16%)
TPut 45    391357.00 (  0.00%)    163075.00 (-58.33%)    365494.00 ( -6.61%)    348089.00 (-11.06%)    414737.00 (  5.97%)
TPut 46    394109.00 (  0.00%)    173557.00 (-55.96%)    357955.00 ( -9.17%)    372188.00 ( -5.56%)    400373.00 (  1.59%)
TPut 47    383292.00 (  0.00%)    168575.00 (-56.02%)    357946.00 ( -6.61%)    352658.00 ( -7.99%)    395851.00 (  3.28%)
TPut 48    373607.00 (  0.00%)    158491.00 (-57.58%)    358227.00 ( -4.12%)    373779.00 (  0.05%)    388631.00 (  4.02%)
TPut 49    372131.00 (  0.00%)    145881.00 (-60.80%)    360147.00 ( -3.22%)    358224.00 ( -3.74%)    377922.00 (  1.56%)
TPut 50    369060.00 (  0.00%)    139450.00 (-62.21%)    355721.00 ( -3.61%)    367608.00 ( -0.39%)    369852.00 (  0.21%)
TPut 51    375906.00 (  0.00%)    139823.00 (-62.80%)    367783.00 ( -2.16%)    364796.00 ( -2.96%)    353863.00 ( -5.86%)
TPut 52    379731.00 (  0.00%)    158706.00 (-58.21%)    381289.00 (  0.41%)    370100.00 ( -2.54%)    379472.00 ( -0.07%)
TPut 53    366656.00 (  0.00%)    178068.00 (-51.43%)    382147.00 (  4.22%)    369301.00 (  0.72%)    376606.00 (  2.71%)
TPut 54    373531.00 (  0.00%)    177087.00 (-52.59%)    374892.00 (  0.36%)    367863.00 ( -1.52%)    372560.00 ( -0.26%)
TPut 55    374440.00 (  0.00%)    174830.00 (-53.31%)    372036.00 ( -0.64%)    377606.00 (  0.85%)    375134.00 (  0.19%)
TPut 56    351285.00 (  0.00%)    175761.00 (-49.97%)    370602.00 (  5.50%)    371896.00 (  5.87%)    366349.00 (  4.29%)
TPut 57    366069.00 (  0.00%)    172227.00 (-52.95%)    377253.00 (  3.06%)    364024.00 ( -0.56%)    367468.00 (  0.38%)
TPut 58    367753.00 (  0.00%)    174523.00 (-52.54%)    376854.00 (  2.47%)    372580.00 (  1.31%)    363218.00 ( -1.23%)
TPut 59    364282.00 (  0.00%)    176119.00 (-51.65%)    365806.00 (  0.42%)    370299.00 (  1.65%)    367422.00 (  0.86%)
TPut 60    372531.00 (  0.00%)    175673.00 (-52.84%)    354662.00 ( -4.80%)    365126.00 ( -1.99%)    372139.00 ( -0.11%)
TPut 61    359648.00 (  0.00%)    174686.00 (-51.43%)    365387.00 (  1.60%)    370039.00 (  2.89%)    368296.00 (  2.40%)
TPut 62    361856.00 (  0.00%)    171420.00 (-52.63%)    366173.00 (  1.19%)    345029.00 ( -4.65%)    368224.00 (  1.76%)
TPut 63    363032.00 (  0.00%)    171603.00 (-52.73%)    360794.00 ( -0.62%)    349379.00 ( -3.76%)    364463.00 (  0.39%)
TPut 64    351549.00 (  0.00%)    170967.00 (-51.37%)    354632.00 (  0.88%)    352406.00 (  0.24%)    365522.00 (  3.97%)
TPut 65    360425.00 (  0.00%)    170349.00 (-52.74%)    346205.00 ( -3.95%)    351510.00 ( -2.47%)    360351.00 ( -0.02%)
TPut 66    359197.00 (  0.00%)    170037.00 (-52.66%)    355970.00 ( -0.90%)    330963.00 ( -7.86%)    347958.00 ( -3.13%)
TPut 67    356962.00 (  0.00%)    168949.00 (-52.67%)    355577.00 ( -0.39%)    358511.00 (  0.43%)    371059.00 (  3.95%)
TPut 68    360411.00 (  0.00%)    167892.00 (-53.42%)    337932.00 ( -6.24%)    358516.00 ( -0.53%)    361518.00 (  0.31%)
TPut 69    354346.00 (  0.00%)    166288.00 (-53.07%)    334951.00 ( -5.47%)    360614.00 (  1.77%)    367286.00 (  3.65%)
TPut 70    354596.00 (  0.00%)    166214.00 (-53.13%)    333059.00 ( -6.07%)    337859.00 ( -4.72%)    350505.00 ( -1.15%)
TPut 71    351838.00 (  0.00%)    167198.00 (-52.48%)    316732.00 ( -9.98%)    350369.00 ( -0.42%)    353104.00 (  0.36%)
TPut 72    357716.00 (  0.00%)    164325.00 (-54.06%)    309282.00 (-13.54%)    353090.00 ( -1.29%)    339898.00 ( -4.98%)

adaptalways reduces the scanning rate on every fault. It mitigates many
of the worse of the regressions but does not eliminate them because there
are still remote faults and migrations.

SPECJBB PEAKS
                                       3.7.0                      3.7.0                      3.7.0                      3.7.0                      3.7.0
                              rc6-stats-v5r1      rc6-numacore-20121123     rc6-autonuma-v28fastr4       rc6-thpmigrate-v6r10      rc6-adaptalways-v6r12
 Expctd Warehouse            48.00 (  0.00%)            48.00 (  0.00%)            48.00 (  0.00%)            48.00 (  0.00%)            48.00 (  0.00%)
 Expctd Peak Bops        373607.00 (  0.00%)        158491.00 (-57.58%)        358227.00 ( -4.12%)        373779.00 (  0.05%)        388631.00 (  4.02%)
 Actual Warehouse            25.00 (  0.00%)            53.00 (112.00%)            23.00 ( -8.00%)            26.00 (  4.00%)            24.00 ( -4.00%)
 Actual Peak Bops        484584.00 (  0.00%)        178068.00 (-63.25%)        436081.00 (-10.01%)        454575.00 ( -6.19%)        486759.00 (  0.45%)
 SpecJBB Bops            185685.00 (  0.00%)         85236.00 (-54.10%)        182329.00 ( -1.81%)        183908.00 ( -0.96%)        186711.00 (  0.55%)
 SpecJBB Bops/JVM        185685.00 (  0.00%)         85236.00 (-54.10%)        182329.00 ( -1.81%)        183908.00 ( -0.96%)        186711.00 (  0.55%)

The actual peak performance figures look ok though and if you were just
looking at the headline figures you might be tempted to conclude that the
patch works but the per-warehouse figures show that it's not really the
case at all.

MMTests Statistics: duration
               3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
        rc6-stats-v5r1rc6-numacore-20121123rc6-autonuma-v28fastr4rc6-thpmigrate-v6r10rc6-adaptalways-v6r12
User       316094.47   169409.35   308316.22   308074.71   309256.18
System         62.67   123927.05     4304.26     1897.43     1650.29
Elapsed      7434.12     7452.00     7439.70     7438.16     7437.24

It does reduce system CPU usage a bit but the fact is that it's still
migrating uselessly.

MMTests Statistics: vmstat
                                 3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
                          rc6-stats-v5r1rc6-numacore-20121123rc6-autonuma-v28fastr4rc6-thpmigrate-v6r10rc6-adaptalways-v6r12
Page Ins                         34248       37888       38048       38148       38076
Page Outs                        50932       60036       54448       55196       55368
Swap Ins                             0           0           0           0           0
Swap Outs                            0           0           0           0           0
Direct pages scanned                 0           0           0           0           0
Kswapd pages scanned                 0           0           0           0           0
Kswapd pages reclaimed               0           0           0           0           0
Direct pages reclaimed               0           0           0           0           0
Kswapd efficiency                 100%        100%        100%        100%        100%
Kswapd velocity                  0.000       0.000       0.000       0.000       0.000
Direct efficiency                 100%        100%        100%        100%        100%
Direct velocity                  0.000       0.000       0.000       0.000       0.000
Percentage direct scans             0%          0%          0%          0%          0%
Page writes by reclaim               0           0           0           0           0
Page writes file                     0           0           0           0           0
Page writes anon                     0           0           0           0           0
Page reclaim immediate               0           0           0           0           0
Page rescued immediate               0           0           0           0           0
Slabs scanned                        0           0           0           0           0
Direct inode steals                  0           0           0           0           0
Kswapd inode steals                  0           0           0           0           0
Kswapd skipped wait                  0           0           0           0           0
THP fault alloc                      3           3           3           3           2
THP collapse alloc                   0           0          12           0           0
THP splits                           0           0           0           0           0
THP fault fallback                   0           0           0           0           0
THP collapse fail                    0           0           0           0           0
Compaction stalls                    0           0           0           0           0
Compaction success                   0           0           0           0           0
Compaction failures                  0           0           0           0           0
Page migrate success                 0           0           0    27257642    22698940
Page migrate failure                 0           0           0           0           0
Compaction pages isolated            0           0           0           0           0
Compaction migrate scanned           0           0           0           0           0
Compaction free scanned              0           0           0           0           0
Compaction cost                      0           0           0       28293       23561
NUMA PTE updates                     0           0           0   220482204   187969232
NUMA hint faults                     0           0           0   214660099   183397210
NUMA hint local faults               0           0           0    55657689    47359679
NUMA pages migrated                  0           0           0    27257642    22698940
AutoNUMA cost                        0           0           0     1075361      918733

Note that it alters the number of PTEs that are updated and the number
of faults but not enough to make a difference. Far too many of those
NUMA faults were remote and resulted in migration.

Here is the "hammer" for reference but I'll not be including it.

---8<---
mm: sched: Adapt the scanning rate even if a NUMA hinting fault migrates

specjbb on single JVM for balancenuma indicated that the scan rate was
not reducing and the performance was impaired. The problem was that
the threads are getting scheduled between nodes and balancenuma is
migrating the pages around in circles uselessly. It needs a scheduling
policy that makes tasks sticker to a node if much of their memory is
there.

In the meantime, I have a hammer and this problems looks mighty like a
nail.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 kernel/sched/fair.c |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index fd9c78c..ed54789 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -818,11 +818,18 @@ void task_numa_fault(int node, int pages, bool migrated)
 
 	/*
 	 * If pages are properly placed (did not migrate) then scan slower.
-	 * This is reset periodically in case of phase changes
+	 * This is reset periodically in case of phase changes. If the page
+	 * was migrated, we still slow the scan rate but less. If the
+	 * workload is not converging at all, at least it will update
+	 * fewer PTEs and stop trashing around but in ideal circumstances it
+	 * also means we converge slower.
 	 */
         if (!migrated)
 		p->numa_scan_period = min(sysctl_balance_numa_scan_period_max,
 			p->numa_scan_period + jiffies_to_msecs(10));
+	else
+		p->numa_scan_period = min(sysctl_balance_numa_scan_period_max,
+			p->numa_scan_period + jiffies_to_msecs(5));
 
 	task_numa_placement(p);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
