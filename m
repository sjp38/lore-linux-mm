Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 58DF76B0035
	for <linux-mm@kvack.org>; Mon, 31 Mar 2014 23:57:06 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id y10so8944256pdj.13
        for <linux-mm@kvack.org>; Mon, 31 Mar 2014 20:57:06 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id sf3si10300656pac.452.2014.03.31.20.57.04
        for <linux-mm@kvack.org>;
        Mon, 31 Mar 2014 20:57:05 -0700 (PDT)
Date: Tue, 1 Apr 2014 11:56:59 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [map_pages] 5449f33f982: +1.7% netperf.Throughput_Mbps
Message-ID: <20140401035659.GA18224@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, lkp@01.org

Hi Kirill,

FYI, we noticed the below (good) changes on

commit 5449f33f982905593117556d9d368d85eea8d13b ("mm: implement ->map_pages for page cache")

d6c1ccefdbdf13a  5449f33f982905593117556d9  
---------------  -------------------------  
      5044 ~ 0%      +1.7%       5128 ~ 0%  lkp-nex05/micro/netperf/120s-200%-TCP_SENDFILE
      5044 ~ 0%      +1.7%       5128 ~ 0%  TOTAL netperf.Throughput_Mbps

d6c1ccefdbdf13a  5449f33f982905593117556d9  
---------------  -------------------------  
   1588009 ~ 2%     -54.9%     716407 ~ 3%  lkp-nex04/micro/netperf/120s-200%-UDP_RR
   1500063 ~ 3%     -55.7%     664357 ~ 4%  lkp-nex05/micro/netperf/120s-200%-TCP_SENDFILE
   3088072 ~ 2%     -55.3%    1380765 ~ 4%  TOTAL proc-vmstat.pgfault

d6c1ccefdbdf13a  5449f33f982905593117556d9  
---------------  -------------------------  
      1446 ~ 0%     +93.0%       2792 ~ 2%  lkp-nex04/micro/netperf/120s-200%-UDP_RR
      1453 ~ 0%     +91.1%       2777 ~ 1%  lkp-nex05/micro/netperf/120s-200%-TCP_SENDFILE
      2900 ~ 0%     +92.1%       5569 ~ 1%  TOTAL time.maximum_resident_set_size

d6c1ccefdbdf13a  5449f33f982905593117556d9  
---------------  -------------------------  
      2.94 ~ 6%     -37.0%       1.85 ~ 4%  lkp-nex04/micro/netperf/120s-200%-UDP_RR
      2.94 ~ 6%     -37.0%       1.85 ~ 4%  TOTAL perf-profile.cpu-cycles.inet_putpeer.__ip_select_ident.__ip_make_skb.ip_make_skb.udp_sendmsg

d6c1ccefdbdf13a  5449f33f982905593117556d9  
---------------  -------------------------  
    272158 ~22%     -28.4%     194888 ~10%  lkp-nex04/micro/netperf/120s-200%-UDP_RR
    272158 ~22%     -28.4%     194888 ~10%  TOTAL numa-vmstat.node1.numa_local

d6c1ccefdbdf13a  5449f33f982905593117556d9  
---------------  -------------------------  
      1.38 ~ 5%     +47.5%       2.04 ~ 2%  lkp-nex04/micro/netperf/120s-200%-UDP_RR
      1.38 ~ 5%     +47.5%       2.04 ~ 2%  TOTAL perf-profile.cpu-cycles.__udp4_lib_lookup.__udp4_lib_rcv.udp_rcv.ip_local_deliver.ip_rcv

d6c1ccefdbdf13a  5449f33f982905593117556d9  
---------------  -------------------------  
    298658 ~20%     -25.7%     221766 ~ 9%  lkp-nex04/micro/netperf/120s-200%-UDP_RR
    298658 ~20%     -25.7%     221766 ~ 9%  TOTAL numa-vmstat.node1.numa_hit

d6c1ccefdbdf13a  5449f33f982905593117556d9  
---------------  -------------------------  
      2.98 ~14%     -22.7%       2.31 ~12%  lkp-nex04/micro/netperf/120s-200%-UDP_RR
      2.98 ~14%     -22.7%       2.31 ~12%  TOTAL perf-profile.cpu-cycles.__ip_select_ident.__ip_make_skb.ip_make_skb.udp_sendmsg.inet_sendmsg

d6c1ccefdbdf13a  5449f33f982905593117556d9  
---------------  -------------------------  
     10092 ~ 4%     +35.2%      13642 ~ 4%  lkp-nex04/micro/netperf/120s-200%-UDP_RR
     10351 ~ 3%     +31.2%      13579 ~ 1%  lkp-nex05/micro/netperf/120s-200%-TCP_SENDFILE
     20443 ~ 3%     +33.2%      27222 ~ 2%  TOTAL meminfo.Mapped

d6c1ccefdbdf13a  5449f33f982905593117556d9  
---------------  -------------------------  
      2470 ~ 1%     +39.0%       3435 ~ 6%  lkp-nex04/micro/netperf/120s-200%-UDP_RR
      2470 ~ 1%     +39.0%       3435 ~ 6%  TOTAL numa-meminfo.node2.Mapped

d6c1ccefdbdf13a  5449f33f982905593117556d9  
---------------  -------------------------  
       620 ~ 1%     +40.1%        868 ~10%  lkp-nex04/micro/netperf/120s-200%-UDP_RR
       620 ~ 1%     +40.1%        868 ~10%  TOTAL numa-vmstat.node2.nr_mapped

d6c1ccefdbdf13a  5449f33f982905593117556d9  
---------------  -------------------------  
       662 ~12%     +24.8%        826 ~ 1%  lkp-nex04/micro/netperf/120s-200%-UDP_RR
       782 ~ 2%     +33.7%       1046 ~ 1%  lkp-nex05/micro/netperf/120s-200%-TCP_SENDFILE
      1444 ~ 6%     +29.7%       1873 ~ 1%  TOTAL numa-vmstat.node1.nr_mapped

d6c1ccefdbdf13a  5449f33f982905593117556d9  
---------------  -------------------------  
       618 ~ 1%     +33.6%        825 ~ 2%  lkp-nex04/micro/netperf/120s-200%-UDP_RR
       780 ~ 2%     +39.0%       1085 ~ 7%  lkp-nex05/micro/netperf/120s-200%-TCP_SENDFILE
      1398 ~ 2%     +36.6%       1911 ~ 5%  TOTAL numa-vmstat.node3.nr_mapped

d6c1ccefdbdf13a  5449f33f982905593117556d9  
---------------  -------------------------  
      2476 ~ 2%     +33.7%       3310 ~ 1%  lkp-nex04/micro/netperf/120s-200%-UDP_RR
      3297 ~11%     +33.4%       4398 ~ 8%  lkp-nex05/micro/netperf/120s-200%-TCP_SENDFILE
      5773 ~ 7%     +33.5%       7709 ~ 5%  TOTAL numa-meminfo.node3.Mapped

d6c1ccefdbdf13a  5449f33f982905593117556d9  
---------------  -------------------------  
      2625 ~10%     +26.8%       3327 ~ 1%  lkp-nex04/micro/netperf/120s-200%-UDP_RR
      3171 ~ 2%     +33.1%       4222 ~ 2%  lkp-nex05/micro/netperf/120s-200%-TCP_SENDFILE
      5796 ~ 5%     +30.3%       7550 ~ 1%  TOTAL numa-meminfo.node1.Mapped

d6c1ccefdbdf13a  5449f33f982905593117556d9  
---------------  -------------------------  
       622 ~ 0%     +33.6%        831 ~ 1%  lkp-nex04/micro/netperf/120s-200%-UDP_RR
       978 ~ 8%     +25.0%       1222 ~ 3%  lkp-nex05/micro/netperf/120s-200%-TCP_SENDFILE
      1601 ~ 5%     +28.3%       2054 ~ 2%  TOTAL numa-vmstat.node0.nr_mapped

d6c1ccefdbdf13a  5449f33f982905593117556d9  
---------------  -------------------------  
      2582 ~ 4%     +32.1%       3412 ~ 2%  lkp-nex04/micro/netperf/120s-200%-UDP_RR
      2542 ~ 2%     +33.5%       3394 ~ 3%  lkp-nex05/micro/netperf/120s-200%-TCP_SENDFILE
      5124 ~ 3%     +32.8%       6806 ~ 2%  TOTAL proc-vmstat.nr_mapped

d6c1ccefdbdf13a  5449f33f982905593117556d9  
---------------  -------------------------  
      2508 ~ 1%     +39.5%       3499 ~ 9%  lkp-nex04/micro/netperf/120s-200%-UDP_RR
      4040 ~10%     +22.6%       4952 ~ 3%  lkp-nex05/micro/netperf/120s-200%-TCP_SENDFILE
      6549 ~ 6%     +29.1%       8452 ~ 5%  TOTAL numa-meminfo.node0.Mapped

d6c1ccefdbdf13a  5449f33f982905593117556d9  
---------------  -------------------------  
     14667 ~ 9%     +12.6%      16520 ~ 9%  lkp-nex04/micro/netperf/120s-200%-UDP_RR
     14667 ~ 9%     +12.6%      16520 ~ 9%  TOTAL numa-meminfo.node3.AnonPages

d6c1ccefdbdf13a  5449f33f982905593117556d9  
---------------  -------------------------  
     14436 ~ 9%     +12.5%      16244 ~10%  lkp-nex04/micro/netperf/120s-200%-UDP_RR
     14436 ~ 9%     +12.5%      16244 ~10%  TOTAL numa-meminfo.node3.Active(anon)

d6c1ccefdbdf13a  5449f33f982905593117556d9  
---------------  -------------------------  
      1.24 ~ 4%     +21.2%       1.50 ~ 7%  lkp-nex04/micro/netperf/120s-200%-UDP_RR
      1.24 ~ 4%     +21.2%       1.50 ~ 7%  TOTAL perf-profile.cpu-cycles.__schedule.schedule.schedule_timeout.__skb_recv_datagram.udp_recvmsg

d6c1ccefdbdf13a  5449f33f982905593117556d9  
---------------  -------------------------  
      1.29 ~ 8%     +12.1%       1.45 ~ 6%  lkp-nex04/micro/netperf/120s-200%-UDP_RR
      1.29 ~ 8%     +12.1%       1.45 ~ 6%  TOTAL perf-profile.cpu-cycles.__ip_route_output_key.ip_route_output_flow.udp_sendmsg.inet_sendmsg.sock_sendmsg

d6c1ccefdbdf13a  5449f33f982905593117556d9  
---------------  -------------------------  
      2825 ~ 4%      +7.4%       3034 ~ 4%  lkp-nex05/micro/netperf/120s-200%-TCP_SENDFILE
      2825 ~ 4%      +7.4%       3034 ~ 4%  TOTAL slabinfo.signal_cache.active_objs

d6c1ccefdbdf13a  5449f33f982905593117556d9  
---------------  -------------------------  
      2825 ~ 4%      +7.8%       3046 ~ 3%  lkp-nex05/micro/netperf/120s-200%-TCP_SENDFILE
      2825 ~ 4%      +7.8%       3046 ~ 3%  TOTAL slabinfo.signal_cache.num_objs

d6c1ccefdbdf13a  5449f33f982905593117556d9  
---------------  -------------------------  
      0.96 ~ 2%      -8.3%       0.88 ~ 1%  lkp-nex05/micro/netperf/120s-200%-TCP_SENDFILE
      0.96 ~ 2%      -8.3%       0.88 ~ 1%  TOTAL perf-profile.cpu-cycles.splice_from_pipe_feed.__splice_from_pipe.splice_from_pipe.generic_splice_sendpage.direct_splice_actor

d6c1ccefdbdf13a  5449f33f982905593117556d9  
---------------  -------------------------  
      5236 ~ 1%     -35.7%       3365 ~ 3%  lkp-nex04/micro/netperf/120s-200%-UDP_RR
      5343 ~ 1%     -35.4%       3449 ~ 1%  lkp-nex05/micro/netperf/120s-200%-TCP_SENDFILE
     10579 ~ 1%     -35.6%       6814 ~ 2%  TOTAL time.minor_page_faults

d6c1ccefdbdf13a  5449f33f982905593117556d9  
---------------  -------------------------  
   2783688 ~ 1%      -1.6%    2738371 ~ 0%  lkp-nex05/micro/netperf/120s-200%-TCP_SENDFILE
   2783688 ~ 1%      -1.6%    2738371 ~ 0%  TOTAL vmstat.system.cs


Legend:
	~XX%    - stddev percent
	[+-]XX% - change percent


                               time.minor_page_faults

   5500 *+---*-----*----*------------*----*-*--*-*---*--*-----------------*-*
        | *.   *.*    *   *.*..*.*.*    *          *      *.*.*..*.*.*.*.   |
        |                                                                   |
   5000 ++                                                                  |
        |                                                                   |
        |                                                                   |
   4500 ++                                                                  |
        |                                                                   |
   4000 ++                                                                  |
        |                                                                   |
        |                                                                   |
   3500 ++       O    O            O           O        O O O               |
        O O  O O   O    O O O  O O   O  O O O    O O O        O  O          |
        |                                                                   |
   3000 ++------------------------------------------------------------------+


	[*] bisect-good sample
	[O] bisect-bad  sample

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
