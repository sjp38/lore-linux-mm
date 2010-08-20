Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 820796B02BD
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 01:26:46 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7K5QgDC007082
	for <linux-mm@kvack.org> (envelope-from iram.shahzad@jp.fujitsu.com);
	Fri, 20 Aug 2010 14:26:42 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 880C645DE4D
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 14:26:42 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6560F45DE60
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 14:26:42 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E0FAFE38002
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 14:26:41 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 756091DB8037
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 14:26:41 +0900 (JST)
Message-ID: <AA3F2D89535A431DB91FE3032EDCB9EA@rainbow>
From: "Iram Shahzad" <iram.shahzad@jp.fujitsu.com>
References: <325E0A25FE724BA18190186F058FF37E@rainbow> <20100817111018.GQ19797@csn.ul.ie> <4385155269B445AEAF27DC8639A953D7@rainbow> <20100818154130.GC9431@localhost> <565A4EE71DAC4B1A820B2748F56ABF73@rainbow> <20100819160006.GG6805@barrios-desktop>
Subject: Re: compaction: trying to understand the code
Date: Fri, 20 Aug 2010 14:31:03 +0900
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_NextPart_000_00CA_01CB4074.51799E60"
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.

------=_NextPart_000_00CA_01CB4074.51799E60
Content-Type: text/plain;
	format=flowed;
	charset="ISO-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit

> Could you apply below patch for debugging and report it?

The Mem-info gets printed forever. So I have picked the first 2 of them
and then another 2 after some time. These 4 Mem-infos are shown in
the attached log.

Thanks
Iram

------=_NextPart_000_00CA_01CB4074.51799E60
Content-Type: text/plain;
	format=flowed;
	name="too_many_isolated_log.txt";
	reply-type=original
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="too_many_isolated_log.txt"

Mem-info:
Normal per-cpu:
CPU    0: hi:  186, btch:  31 usd: 184
active_anon:40345 inactive_anon:0 isolated_anon:8549
 active_file:2713 inactive_file:10418 isolated_file:1871
 unevictable:0 dirty:0 writeback:0 unstable:0
 free:53713 slab_reclaimable:533 slab_unreclaimable:1076
 mapped:9461 shmem:2349 pagetables:1574 bounce:0
Normal free:214852kB min:2884kB low:3604kB high:4324kB =
active_anon:161380kB inactive_anon:0kB active_file:10852kB =
inactive_file:41672kB unevictable:0kB isolated(anon):34196kB =
isolated(file):7484kB present:520192kB mlocked:0kB dirty:0kB =
writeback:0kB mapped:37844kB shmem:9396kB slab_reclaimable:2132kB =
slab_unreclaimable:4304kB kernel_stack:1880kB pagetables:6296kB =
unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 =
all_unreclaimable? no
lowmem_reserve[]: 0 0 0
Normal: 31*4kB 29*8kB 20*16kB 23*32kB 21*64kB 19*128kB 19*256kB 20*512kB =
20*1024kB 3*2048kB 41*4096kB =3D 214852kB
15491 total pagecache pages
131072 pages of RAM
54242 free pages
18897 reserved pages
1609 slab pages
84316 pages shared
0 pages swap cached
Mem-info:
Normal per-cpu:
CPU    0: hi:  186, btch:  31 usd: 184
active_anon:40345 inactive_anon:0 isolated_anon:8549
 active_file:2713 inactive_file:10418 isolated_file:1871
 unevictable:0 dirty:0 writeback:0 unstable:0
 free:53713 slab_reclaimable:533 slab_unreclaimable:1076
 mapped:9461 shmem:2349 pagetables:1574 bounce:0
Normal free:214852kB min:2884kB low:3604kB high:4324kB =
active_anon:161380kB inactive_anon:0kB active_file:10852kB =
inactive_file:41672kB unevictable:0kB isolated(anon):34196kB =
isolated(file):7484kB present:520192kB mlocked:0kB dirty:0kB =
writeback:0kB mapped:37844kB shmem:9396kB slab_reclaimable:2132kB =
slab_unreclaimable:4304kB kernel_stack:1880kB pagetables:6296kB =
unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 =
all_unreclaimable? no
lowmem_reserve[]: 0 0 0
Normal: 26*4kB 27*8kB 19*16kB 22*32kB 20*64kB 19*128kB 19*256kB 20*512kB =
20*1024kB 3*2048kB 41*4096kB =3D 214704kB
15491 total pagecache pages
131072 pages of RAM
54258 free pages
18897 reserved pages
1609 slab pages
84296 pages shared
0 pages swap cached


[snip]


Mem-info:
Normal per-cpu:
CPU    0: hi:  186, btch:  31 usd: 100
active_anon:40429 inactive_anon:0 isolated_anon:8581
 active_file:2719 inactive_file:10423 isolated_file:1871
 unevictable:0 dirty:0 writeback:0 unstable:0
 free:53777 slab_reclaimable:534 slab_unreclaimable:1070
 mapped:9461 shmem:2349 pagetables:1574 bounce:0
Normal free:215108kB min:2884kB low:3604kB high:4324kB =
active_anon:161716kB inactive_anon:0kB active_file:10876kB =
inactive_file:41692kB unevictable:0kB isolated(anon):34324kB =
isolated(file):7484kB present:520192kB mlocked:0kB dirty:0kB =
writeback:0kB mapped:37844kB shmem:9396kB slab_reclaimable:2136kB =
slab_unreclaimable:4280kB kernel_stack:1872kB pagetables:6296kB =
unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 =
all_unreclaimable? no
lowmem_reserve[]: 0 0 0
Normal: 31*4kB 29*8kB 20*16kB 21*32kB 22*64kB 19*128kB 20*256kB 20*512kB =
20*1024kB 3*2048kB 41*4096kB =3D 215108kB
15491 total pagecache pages
131072 pages of RAM
54221 free pages
18897 reserved pages
1604 slab pages
84289 pages shared
0 pages swap cached
Mem-info:
Normal per-cpu:
CPU    0: hi:  186, btch:  31 usd: 100
active_anon:40429 inactive_anon:0 isolated_anon:8581
 active_file:2719 inactive_file:10423 isolated_file:1871
 unevictable:0 dirty:0 writeback:0 unstable:0
 free:53777 slab_reclaimable:534 slab_unreclaimable:1070
 mapped:9461 shmem:2349 pagetables:1574 bounce:0
Normal free:215108kB min:2884kB low:3604kB high:4324kB =
active_anon:161716kB inactive_anon:0kB active_file:10876kB =
inactive_file:41692kB unevictable:0kB isolated(anon):34324kB =
isolated(file):7484kB present:520192kB mlocked:0kB dirty:0kB =
writeback:0kB mapped:37844kB shmem:9396kB slab_reclaimable:2136kB =
slab_unreclaimable:4280kB kernel_stack:1872kB pagetables:6296kB =
unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 =
all_unreclaimable? no
lowmem_reserve[]: 0 0 0
Normal: 31*4kB 29*8kB 20*16kB 21*32kB 22*64kB 19*128kB 20*256kB 20*512kB =
20*1024kB 3*2048kB 41*4096kB =3D 215108kB
15491 total pagecache pages
131072 pages of RAM
54222 free pages
18897 reserved pages
1603 slab pages
84289 pages shared
0 pages swap cached

------=_NextPart_000_00CA_01CB4074.51799E60--


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
