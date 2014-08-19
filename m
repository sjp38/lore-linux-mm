Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id CC6AC6B0035
	for <linux-mm@kvack.org>; Tue, 19 Aug 2014 08:16:27 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id lj1so9857552pab.5
        for <linux-mm@kvack.org>; Tue, 19 Aug 2014 05:16:27 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id ao2si26651253pad.12.2014.08.19.05.16.08
        for <linux-mm@kvack.org>;
        Tue, 19 Aug 2014 05:16:09 -0700 (PDT)
Date: Tue, 19 Aug 2014 20:12:30 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [memcontrol] 05b84301233: +129.9% vm-scalability.throughput, -12.6%
 turbostat.Pkg_W
Message-ID: <20140819121230.GD18960@localhost>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="WhfpMioaduB5tiZL"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, lkp@01.org


--WhfpMioaduB5tiZL
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

Hi Johannes,

We find interesting multi-thread mmap rand read performance gain and
power reduction on

commit 05b8430123359886ef6a4146fba384e30d771b3f ("mm: memcontrol: use root_mem_cgroup res_counter")

test case: brickland3/vm-scalability/300s-mmap-pread-rand-mt

The test box "brickland3" is Brickland Ivy Bridge-EX with 512G memory,
120 logical CPUs.

692e7c45d95ad10  05b8430123359886ef6a4146f 
---------------  ------------------------- 
      0.03 A+-100%  +12170.5%       3.13 A+-50%  TOTAL vm-scalability.stddev
   1282439 A+-10%    +129.9%    2947754 A+-22%  TOTAL vm-scalability.throughput
     24056 A+-17%   +1619.6%     413661 A+-40%  TOTAL numa-vmstat.node0.nr_active_file
    374762 A+-13%    +403.4%    1886450 A+-33%  TOTAL numa-vmstat.node3.nr_mapped
     26019 A+-20%   +1798.6%     494013 A+-40%  TOTAL numa-vmstat.node3.nr_active_file
    352052 A+-13%    +352.0%    1591441 A+-33%  TOTAL numa-vmstat.node0.nr_mapped
   1499575 A+-13%    +403.4%    7549434 A+-33%  TOTAL numa-meminfo.node3.Mapped
      0.01 A+- 0%  +6.2e+05%      62.16 A+-49%  TOTAL perf-profile.cpu-cycles.do_unit
   1488742 A+-20%    +377.0%    7101311 A+-33%  TOTAL numa-meminfo.node2.Mapped
    102414 A+-20%   +1723.4%    1867451 A+-40%  TOTAL numa-meminfo.node2.Active(file)
      2.37 A+-27%    +636.7%      17.46 A+-35%  TOTAL turbostat.%c6
    143698 A+-16%   +1205.1%    1875367 A+-36%  TOTAL numa-meminfo.node1.Active(file)
    151914 A+-16%   +1273.9%    2087141 A+-30%  TOTAL numa-meminfo.node1.Active
    103946 A+-20%   +1803.3%    1978406 A+-40%  TOTAL numa-meminfo.node3.Active(file)
   1408602 A+-13%    +352.1%    6368584 A+-33%  TOTAL numa-meminfo.node0.Mapped
     96122 A+-17%   +1623.5%    1656668 A+-40%  TOTAL numa-meminfo.node0.Active(file)
    372146 A+-20%    +376.8%    1774356 A+-33%  TOTAL numa-vmstat.node2.nr_mapped
     35970 A+-16%   +1201.8%     468251 A+-36%  TOTAL numa-vmstat.node1.nr_active_file
    441937 A+-17%   +1561.9%    7344724 A+-39%  TOTAL meminfo.Active(file)
    110544 A+-17%   +1560.6%    1835659 A+-39%  TOTAL proc-vmstat.nr_active_file
   1120643 A+- 5%    +590.6%    7739311 A+-35%  TOTAL meminfo.Active
  18371498 A+- 3%    +453.4%  1.017e+08 A+-35%  TOTAL proc-vmstat.pgfault
     25633 A+-20%   +1719.1%     466289 A+-40%  TOTAL numa-vmstat.node2.nr_active_file
   6658192 A+-11%    +324.6%   28272474 A+-31%  TOTAL meminfo.Mapped
   1665171 A+-11%    +324.2%    7063886 A+-31%  TOTAL proc-vmstat.nr_mapped
   2428188 A+- 9%    +227.6%    7953909 A+-30%  TOTAL numa-meminfo.node3.FilePages
    606895 A+- 9%    +227.5%    1987651 A+-30%  TOTAL numa-vmstat.node3.nr_file_pages
    569759 A+- 5%    +219.4%    1819531 A+-26%  TOTAL numa-vmstat.node1.nr_mapped
   2279554 A+- 5%    +219.4%    7281938 A+-26%  TOTAL numa-meminfo.node1.Mapped
    556008 A+-25%    +232.5%    1848486 A+-32%  TOTAL numa-vmstat.node2.nr_file_pages
   2224676 A+-25%    +232.5%    7397397 A+-32%  TOTAL numa-meminfo.node2.FilePages
    533395 A+-27%    +209.0%    1648097 A+-32%  TOTAL numa-vmstat.node0.nr_file_pages
   2134139 A+-27%    +209.0%    6594790 A+-32%  TOTAL numa-meminfo.node0.FilePages
  10069745 A+-18%    +196.2%   29824943 A+-28%  TOTAL vmstat.memory.cache
  10095876 A+-18%    +195.9%   29875905 A+-28%  TOTAL meminfo.Cached
   2525023 A+-18%    +195.6%    7464604 A+-28%  TOTAL proc-vmstat.nr_file_pages
   1969114 A+-20%    +195.7%    5823012 A+-28%  TOTAL numa-meminfo.node3.Inactive
   1962869 A+-20%    +196.5%    5820705 A+-28%  TOTAL numa-meminfo.node3.Inactive(file)
    490557 A+-20%    +196.6%    1454975 A+-28%  TOTAL numa-vmstat.node3.nr_inactive_file
   1790247 A+-19%    +175.7%    4935454 A+-29%  TOTAL numa-meminfo.node0.Inactive(file)
    447375 A+-19%    +175.8%    1233766 A+-29%  TOTAL numa-vmstat.node0.nr_inactive_file
   1794406 A+-19%    +175.1%    4936742 A+-29%  TOTAL numa-meminfo.node0.Inactive
       117 A+-10%     -48.4%         60 A+-49%  TOTAL proc-vmstat.nr_dirtied
   3371503 A+- 9%    +143.2%    8198318 A+-20%  TOTAL proc-vmstat.pgactivate
   2184713 A+-20%    +150.4%    5470979 A+-26%  TOTAL proc-vmstat.nr_inactive_file
   8735108 A+-20%    +150.7%   21899817 A+-26%  TOTAL meminfo.Inactive(file)
   3337503 A+-17%    +138.4%    7957665 A+-22%  TOTAL numa-meminfo.node1.FilePages
    834094 A+-17%    +138.4%    1988537 A+-22%  TOTAL numa-vmstat.node1.nr_file_pages
   9002304 A+-19%    +146.2%   22163923 A+-26%  TOTAL meminfo.Inactive
   5007211 A+- 4%    +116.0%   10818062 A+-22%  TOTAL numa-meminfo.node3.MemUsed
   4817372 A+-11%    +112.8%   10252314 A+-23%  TOTAL numa-meminfo.node2.MemUsed
   4748497 A+-11%     +99.7%    9482674 A+-22%  TOTAL numa-meminfo.node0.MemUsed
    678705 A+- 3%     -41.9%     394587 A+-31%  TOTAL meminfo.Active(anon)
    169636 A+- 3%     -41.8%      98684 A+-31%  TOTAL proc-vmstat.nr_active_anon
   3037702 A+-18%     +86.6%    5666857 A+-20%  TOTAL numa-meminfo.node1.Inactive(file)
    759113 A+-18%     +86.6%    1416427 A+-20%  TOTAL numa-vmstat.node1.nr_inactive_file
      3.06 A+-12%     +88.8%       5.77 A+-12%  TOTAL turbostat.%c1
   3191174 A+-18%     +84.1%    5875267 A+-19%  TOTAL numa-meminfo.node1.Inactive
   6070097 A+- 9%     +80.0%   10923602 A+-16%  TOTAL numa-meminfo.node1.MemUsed
       162 A+- 6%     -34.6%        106 A+-28%  TOTAL proc-vmstat.nr_written
      8361 A+- 2%     +61.1%      13473 A+-15%  TOTAL uptime.idle
    914728 A+- 2%     -31.3%     628385 A+-20%  TOTAL meminfo.Shmem
    228644 A+- 2%     -31.3%     157110 A+-20%  TOTAL proc-vmstat.nr_shmem
     93589 A+-12%     +54.2%     144291 A+-12%  TOTAL slabinfo.radix_tree_node.num_objs
      1670 A+-12%     +54.2%       2576 A+-12%  TOTAL slabinfo.radix_tree_node.num_slabs
      1670 A+-12%     +54.2%       2576 A+-12%  TOTAL slabinfo.radix_tree_node.active_slabs
     93251 A+-12%     +54.0%     143616 A+-12%  TOTAL slabinfo.radix_tree_node.active_objs
      5789 A+- 9%     +37.5%       7958 A+- 4%  TOTAL numa-vmstat.node3.nr_slab_reclaimable
     23161 A+- 9%     +37.5%      31844 A+- 4%  TOTAL numa-meminfo.node3.SReclaimable
   2014435 A+- 2%     -23.4%    1542102 A+- 9%  TOTAL meminfo.Committed_AS
  25777315 A+-10%     -26.9%   18834186 A+- 3%  TOTAL softirqs.TIMER
     98593 A+- 6%     +29.1%     127310 A+- 8%  TOTAL meminfo.SReclaimable
     24651 A+- 6%     +29.1%      31817 A+- 8%  TOTAL proc-vmstat.nr_slab_reclaimable
       114 A+- 0%     -19.2%         92 A+- 8%  TOTAL vmstat.procs.r
     54218 A+- 6%     +17.0%      63418 A+- 6%  TOTAL numa-meminfo.node2.Slab
    432162 A+- 1%     +17.4%     507299 A+- 4%  TOTAL numa-vmstat.node3.nr_page_table_pages
   1729816 A+- 1%     +17.3%    2029692 A+- 4%  TOTAL numa-meminfo.node3.PageTables
   6918899 A+- 1%     +16.4%    8056526 A+- 3%  TOTAL meminfo.PageTables
   1730406 A+- 1%     +16.3%    2012726 A+- 3%  TOTAL proc-vmstat.nr_page_table_pages
   1732736 A+- 1%     +17.2%    2030910 A+- 3%  TOTAL numa-meminfo.node0.PageTables
   1735229 A+- 1%     +15.9%    2011761 A+- 3%  TOTAL numa-meminfo.node2.PageTables
    432880 A+- 1%     +17.2%     507504 A+- 3%  TOTAL numa-vmstat.node0.nr_page_table_pages
    433466 A+- 1%     +16.0%     502747 A+- 3%  TOTAL numa-vmstat.node2.nr_page_table_pages
    433015 A+- 1%     +14.5%     495963 A+- 3%  TOTAL numa-vmstat.node1.nr_page_table_pages
   1733140 A+- 1%     +14.5%    1984694 A+- 3%  TOTAL numa-meminfo.node1.PageTables
     55586 A+- 4%     +14.6%      63699 A+- 5%  TOTAL numa-meminfo.node3.Slab
    235040 A+- 2%     +12.0%     263152 A+- 3%  TOTAL meminfo.Slab
    129349 A+- 4%     -10.5%     115832 A+- 7%  TOTAL meminfo.DirectMap4k
   4428414 A+-23%   +2068.0%   96008011 A+-40%  TOTAL time.minor_page_faults
     94.57 A+- 0%     -18.8%      76.76 A+- 8%  TOTAL turbostat.%c0
     11277 A+- 0%     -18.5%       9191 A+- 7%  TOTAL time.percent_of_cpu_this_job_got
       391 A+- 0%     -15.1%        332 A+- 6%  TOTAL turbostat.Cor_W
       461 A+- 0%     -12.6%        403 A+- 5%  TOTAL turbostat.Pkg_W
    208054 A+-15%     -19.3%     167943 A+- 4%  TOTAL time.involuntary_context_switches

Disclaimer:
Results have been estimated based on internal Intel analysis and are provided
for informational purposes only. Any difference in system hardware or software
design or configuration may affect actual performance.

Thanks,
Fengguang

--WhfpMioaduB5tiZL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=reproduce

echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu10/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu100/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu101/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu102/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu103/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu104/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu105/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu106/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu107/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu108/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu109/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu11/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu110/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu111/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu112/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu113/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu114/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu115/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu116/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu117/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu118/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu119/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu12/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu13/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu14/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu15/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu16/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu17/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu18/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu19/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu20/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu21/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu22/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu23/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu24/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu25/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu26/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu27/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu28/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu29/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu30/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu31/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu32/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu33/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu34/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu35/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu36/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu37/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu38/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu39/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu40/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu41/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu42/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu43/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu44/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu45/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu46/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu47/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu48/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu49/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu5/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu50/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu51/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu52/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu53/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu54/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu55/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu56/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu57/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu58/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu59/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu6/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu60/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu61/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu62/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu63/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu64/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu65/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu66/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu67/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu68/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu69/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu7/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu70/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu71/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu72/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu73/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu74/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu75/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu76/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu77/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu78/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu79/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu8/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu80/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu81/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu82/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu83/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu84/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu85/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu86/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu87/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu88/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu89/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu9/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu90/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu91/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu92/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu93/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu94/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu95/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu96/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu97/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu98/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu99/cpufreq/scaling_governor
mount -t tmpfs -o size=100% vm-scalability-tmp /tmp/vm-scalability-tmp
truncate -s 540952072192 /tmp/vm-scalability.img
mkfs.xfs -q /tmp/vm-scalability.img
mount -o loop /tmp/vm-scalability.img /tmp/vm-scalability
./case-mmap-pread-rand-mt
truncate /tmp/vm-scalability/sparse-mmap-pread-rand-mt -s 36650387592
./usemem --runtime 300 -t 120 -f /tmp/vm-scalability/sparse-mmap-pread-rand-mt --readonly --random 36650387592
umount /tmp/vm-scalability-tmp
umount /tmp/vm-scalability
rm /tmp/vm-scalability.img

--WhfpMioaduB5tiZL--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
