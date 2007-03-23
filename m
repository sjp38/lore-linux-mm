Date: Fri, 23 Mar 2007 10:54:12 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [QUICKLIST 1/5] Quicklists for page table pages V4
In-Reply-To: <Pine.LNX.4.64.0703230804120.21857@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0703231026490.23132@schroedinger.engr.sgi.com>
References: <20070323062843.19502.19827.sendpatchset@schroedinger.engr.sgi.com>
 <20070322223927.bb4caf43.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0703222339560.19630@schroedinger.engr.sgi.com>
 <20070322234848.100abb3d.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0703230804120.21857@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Here are the results of aim9 tests on x86_64. There are some minor performance 
improvements and some fluctuations. Page size is only a fourth of that on 
ia64 so the resulting benefit is less in terms of saved cacheline fetches.

The benefit is also likely higher on i386 because it can fit double the 
page table entries into a page.

 1 add_double   1096039.60 1096039.60       0.00  0.00% Thousand Double Precision Additions/second
 2 add_float    1087128.71 1099009.90   11881.19  1.09% Thousand Single Precision Additions/second
 3 add_long     4019704.43 4374384.24  354679.81  8.82% Thousand Long Integer Additions/second
 4 add_int      3772277.23 3772277.23       0.00  0.00% Thousand Integer Additions/second
 5 add_short    3754455.45 3761194.03    6738.58  0.18% Thousand Short Integer Additions/second
 6 creat-clo    259405.94 267164.18      7758.24  2.99% File Creations and Closes/second
 7 page_test    233118.81 235970.15      2851.34  1.22% System Allocations & Pages/second
 8 brk_test     3425247.52 3408457.71  -16789.81 -0.49% System Memory Allocations/second
 9 jmp_test     21819306.93 21808457.71 -10849.22 -0.05% Non-local gotos/second
10 signal_test  669154.23 689552.24     20398.01  3.05% Signal Traps/second
11 exec_test    747.52 743.78              -3.74 -0.50% Program Loads/second
12 fork_test    8267.33 8457.71           190.38  2.30% Task Creations/second
13 link_test    43819.31 44318.32         499.01  1.14% Link/Unlink Pairs/second
28 fun_cal      326463366.34 326559203.98 95837.64 0.03% Function Calls (no arguments)/second
29 fun_cal1     358906930.69 388202985.07 29296054.38 8.16% Function Calls (1 argument)/second
30 fun_cal2     356372277.23 356362189.05 -10088.18 -0.00% Function Calls (2 arguments)/second
31 fun_cal15    156641584.16 156656716.42 15132.26  0.01% Function Calls (15 arguments)/second
45 mem_rtns_2   1588762.38 1610298.51   21536.13  1.36% Block Memory Operations/second
46 sort_rtns_1  935.32 1004.98             69.66  7.45% Sort Operations/second
47 misc_rtns_1  17099.01 17268.66         169.65  0.99% Auxiliary Loops/second
48 dir_rtns_1   5925742.57 6313432.84  387690.27  6.54% Directory Operations/second
52 series_1     11469950.50 11625771.14 155820.64 1.36% Series Evaluations/second
53 shared_memory 1187313.43 1177910.45  -9402.98 -0.79% Shared Memory Operations/second
54 tcp_test     83183.17 83507.46         324.29  0.39% TCP/IP Messages/second
55 udp_test     273514.85 269801.00     -3713.85 -1.36% UDP/IP DataGrams/second
56 fifo_test    741237.62 803930.35     62692.73  8.46% FIFO Messages/second
57 stream_pipe  885099.01 1058059.70   172960.69 19.54% Stream Pipe Messages/second
58 dgram_pipe   881782.18 957213.93     75431.75  8.55% DataGram Pipe Messages/second
59 pipe_cpy     1355891.09 1316766.17  -39124.92 -2.89% Pipe Messages/second


2.6.21-rc4 bare

------------------------------------------------------------------------------------------------------------
 Test        Test        Elapsed  Iteration    Iteration          Operation
Number       Name      Time (sec)   Count   Rate (loops/sec)    Rate (ops/sec)
------------------------------------------------------------------------------------------------------------
     1 add_double           2.02        123   60.89109      1096039.60 Thousand Double Precision Additions/second
     2 add_float            2.02        183   90.59406      1087128.71 Thousand Single Precision Additions/second
     3 add_long             2.03        136   66.99507      4019704.43 Thousand Long Integer Additions/second
     4 add_int              2.02        127   62.87129      3772277.23 Thousand Integer Additions/second
     5 add_short            2.02        316  156.43564      3754455.45 Thousand Short Integer Additions/second
     6 creat-clo            2.02        524  259.40594       259405.94 File Creations and Closes/second
     7 page_test            2.02        277  137.12871       233118.81 System Allocations & Pages/second
     8 brk_test             2.02        407  201.48515      3425247.52 System Memory Allocations/second
     9 jmp_test             2.02      44075 21819.30693     21819306.93 Non-local gotos/second
    10 signal_test          2.01       1345  669.15423       669154.23 Signal Traps/second
    11 exec_test            2.02        302  149.50495          747.52 Program Loads/second
    12 fork_test            2.02        167   82.67327         8267.33 Task Creations/second
    13 link_test            2.02       1405  695.54455        43819.31 Link/Unlink Pairs/second
    14 disk_rr              2.02         65   32.17822       164752.48 Random Disk Reads (K)/second
    15 disk_rw              2.03         55   27.09360       138719.21 Random Disk Writes (K)/second
    16 disk_rd              2.02        467  231.18812      1183683.17 Sequential Disk Reads (K)/second
    17 disk_wrt             2.02         81   40.09901       205306.93 Sequential Disk Writes (K)/second
    18 disk_cp              2.04         65   31.86275       163137.25 Disk Copies (K)/second
    19 sync_disk_rw         2.05          2    0.97561         2497.56 Sync Random Disk Writes (K)/second
    20 sync_disk_wrt        2.15          1    0.46512         1190.70 Sync Sequential Disk Writes (K)/second
    21 sync_disk_cp         2.49          1    0.40161         1028.11 Sync Disk Copies (K)/second
    22 disk_src             2.02       1049  519.30693        38948.02 Directory Searches/second
    23 div_double           2.02        141   69.80198       209405.94 Thousand Double Precision Divides/second
    24 div_float            2.02        141   69.80198       209405.94 Thousand Single Precision Divides/second
    25 div_long             2.04         68   33.33333        30000.00 Thousand Long Integer Divides/second
    26 div_int              2.02        120   59.40594        53465.35 Thousand Integer Divides/second
    27 div_short            2.03        119   58.62069        52758.62 Thousand Short Integer Divides/second
    28 fun_cal              2.02       1288  637.62376    326463366.34 Function Calls (no arguments)/second
    29 fun_cal1             2.02       1416  700.99010    358906930.69 Function Calls (1 argument)/second
    30 fun_cal2             2.02       1406  696.03960    356372277.23 Function Calls (2 arguments)/second
    31 fun_cal15            2.02        618  305.94059    156641584.16 Function Calls (15 arguments)/second
    32 sieve                2.15         10    4.65116           23.26 Integer Sieves/second
    33 mul_double           2.02        185   91.58416      1099009.90 Thousand Double Precision Multiplies/second
    34 mul_float            2.02        185   91.58416      1099009.90 Thousand Single Precision Multiplies/second
    35 mul_long             2.02       6129 3034.15842       728198.02 Thousand Long Integer Multiplies/second
    36 mul_int              2.02       8517 4216.33663      1011920.79 Thousand Integer Multiplies/second
    37 mul_short            2.02       6817 3374.75248      1012425.74 Thousand Short Integer Multiplies/second
    38 num_rtns_1           2.02       6260 3099.00990       309900.99 Numeric Functions/second
    39 new_raph             2.02       6305 3121.28713       624257.43 Zeros Found/second
    40 trig_rtns            2.02        243  120.29703      1202970.30 Trigonometric Functions/second
    41 matrix_rtns          2.02      69718 34513.86139      3451386.14 Point Transformations/second
    42 array_rtns           2.01        165   82.08955         1641.79 Linear Systems Solved/second
    43 string_rtns          2.02        120   59.40594         5940.59 String Manipulations/second
    44 mem_rtns_1           2.02        370  183.16832      5495049.50 Dynamic Memory Operations/second
    45 mem_rtns_2           2.02      32093 15887.62376      1588762.38 Block Memory Operations/second
    46 sort_rtns_1          2.01        188   93.53234          935.32 Sort Operations/second
    47 misc_rtns_1          2.02       3454 1709.90099        17099.01 Auxiliary Loops/second
    48 dir_rtns_1           2.02       1197  592.57426      5925742.57 Directory Operations/second
    49 shell_rtns_1         2.02        328  162.37624          162.38 Shell Scripts/second
    50 shell_rtns_2         2.02        327  161.88119          161.88 Shell Scripts/second
    51 shell_rtns_3         2.02        327  161.88119          161.88 Shell Scripts/second
    52 series_1             2.02     231693 114699.50495     11469950.50 Series Evaluations/second
    53 shared_memory        2.01      23865 11873.13433      1187313.43 Shared Memory Operations/second
    54 tcp_test             2.02       1867  924.25743        83183.17 TCP/IP Messages/second
    55 udp_test             2.02       5525 2735.14851       273514.85 UDP/IP DataGrams/second
    56 fifo_test            2.02      14973 7412.37624       741237.62 FIFO Messages/second
    57 stream_pipe          2.02      17879 8850.99010       885099.01 Stream Pipe Messages/second
    58 dgram_pipe           2.02      17812 8817.82178       881782.18 DataGram Pipe Messages/second
    59 pipe_cpy             2.02      27389 13558.91089      1355891.09 Pipe Messages/second
    60 ram_copy             2.02     353141 174822.27723   4374053376.24 Memory to Memory Copy/second

2.6.21-rc4 x86_64 quicklist

------------------------------------------------------------------------------------------------------------
 Test        Test        Elapsed  Iteration    Iteration          Operation
Number       Name      Time (sec)   Count   Rate (loops/sec)    Rate (ops/sec)
------------------------------------------------------------------------------------------------------------
     1 add_double           2.02        123   60.89109      1096039.60 Thousand Double Precision Additions/second
     2 add_float            2.02        185   91.58416      1099009.90 Thousand Single Precision Additions/second
     3 add_long             2.03        148   72.90640      4374384.24 Thousand Long Integer Additions/second
     4 add_int              2.02        127   62.87129      3772277.23 Thousand Integer Additions/second
     5 add_short            2.01        315  156.71642      3761194.03 Thousand Short Integer Additions/second
     6 creat-clo            2.01        537  267.16418       267164.18 File Creations and Closes/second
     7 page_test            2.01        279  138.80597       235970.15 System Allocations & Pages/second
     8 brk_test             2.01        403  200.49751      3408457.71 System Memory Allocations/second
     9 jmp_test             2.01      43835 21808.45771     21808457.71 Non-local gotos/second
    10 signal_test          2.01       1386  689.55224       689552.24 Signal Traps/second
    11 exec_test            2.01        299  148.75622          743.78 Program Loads/second
    12 fork_test            2.01        170   84.57711         8457.71 Task Creations/second
    13 link_test            2.02       1421  703.46535        44318.32 Link/Unlink Pairs/second
    14 disk_rr              2.01         63   31.34328       160477.61 Random Disk Reads (K)/second
    15 disk_rw              2.02         53   26.23762       134336.63 Random Disk Writes (K)/second
    16 disk_rd              2.01        498  247.76119      1268537.31 Sequential Disk Reads (K)/second
    17 disk_wrt             2.02         78   38.61386       197702.97 Sequential Disk Writes (K)/second
    18 disk_cp              2.04         64   31.37255       160627.45 Disk Copies (K)/second
    19 sync_disk_rw         2.65          2    0.75472         1932.08 Sync Random Disk Writes (K)/second
    20 sync_disk_wrt        3.96          2    0.50505         1292.93 Sync Sequential Disk Writes (K)/second
    21 sync_disk_cp         2.31          1    0.43290         1108.23 Sync Disk Copies (K)/second
    22 disk_src             2.01       1079  536.81592        40261.19 Directory Searches/second
    23 div_double           2.02        141   69.80198       209405.94 Thousand Double Precision Divides/second
    24 div_float            2.01        140   69.65174       208955.22 Thousand Single Precision Divides/second
    25 div_long             2.01         67   33.33333        30000.00 Thousand Long Integer Divides/second
    26 div_int              2.02        120   59.40594        53465.35 Thousand Integer Divides/second
    27 div_short            2.01        118   58.70647        52835.82 Thousand Short Integer Divides/second
    28 fun_cal              2.01       1282  637.81095    326559203.98 Function Calls (no arguments)/second
    29 fun_cal1             2.01       1524  758.20896    388202985.07 Function Calls (1 argument)/second
    30 fun_cal2             2.01       1399  696.01990    356362189.05 Function Calls (2 arguments)/second
    31 fun_cal15            2.01        615  305.97015    156656716.42 Function Calls (15 arguments)/second
    32 sieve                2.16         10    4.62963           23.15 Integer Sieves/second
    33 mul_double           2.02        185   91.58416      1099009.90 Thousand Double Precision Multiplies/second
    34 mul_float            2.02        185   91.58416      1099009.90 Thousand Single Precision Multiplies/second
    35 mul_long             2.02       6128 3033.66337       728079.21 Thousand Long Integer Multiplies/second
    36 mul_int              2.01       8475 4216.41791      1011940.30 Thousand Integer Multiplies/second
    37 mul_short            2.01       6783 3374.62687      1012388.06 Thousand Short Integer Multiplies/second
    38 num_rtns_1           2.01       6264 3116.41791       311641.79 Numeric Functions/second
    39 new_raph             2.01       6261 3114.92537       622985.07 Zeros Found/second
    40 trig_rtns            2.01        239  118.90547      1189054.73 Trigonometric Functions/second
    41 matrix_rtns          2.01      69555 34604.47761      3460447.76 Point Transformations/second
    42 array_rtns           2.01        165   82.08955         1641.79 Linear Systems Solved/second
    43 string_rtns          2.01        118   58.70647         5870.65 String Manipulations/second
    44 mem_rtns_1           2.01        370  184.07960      5522388.06 Dynamic Memory Operations/second
    45 mem_rtns_2           2.01      32367 16102.98507      1610298.51 Block Memory Operations/second
    46 sort_rtns_1          2.01        202  100.49751         1004.98 Sort Operations/second
    47 misc_rtns_1          2.01       3471 1726.86567        17268.66 Auxiliary Loops/second
    48 dir_rtns_1           2.01       1269  631.34328      6313432.84 Directory Operations/second
    49 shell_rtns_1         2.01        321  159.70149          159.70 Shell Scripts/second
    50 shell_rtns_2         2.01        324  161.19403          161.19 Shell Scripts/second
    51 shell_rtns_3         2.01        325  161.69154          161.69 Shell Scripts/second
    52 series_1             2.01     233678 116257.71144     11625771.14 Series Evaluations/second
    53 shared_memory        2.01      23676 11779.10448      1177910.45 Shared Memory Operations/second
    54 tcp_test             2.01       1865  927.86070        83507.46 TCP/IP Messages/second
    55 udp_test             2.01       5423 2698.00995       269801.00 UDP/IP DataGrams/second
    56 fifo_test            2.01      16159 8039.30348       803930.35 FIFO Messages/second
    57 stream_pipe          2.01      21267 10580.59701      1058059.70 Stream Pipe Messages/second
    58 dgram_pipe           2.01      19240 9572.13930       957213.93 DataGram Pipe Messages/second
    59 pipe_cpy             2.01      26467 13167.66169      1316766.17 Pipe Messages/second
    60 ram_copy             2.01     351052 174652.73632   4369811462.69 Memory to Memory Copy/second

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
