Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 270F56B0006
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 07:50:02 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id t9-v6so2683335ybb.2
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 04:50:02 -0700 (PDT)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id i14-v6si228298ybe.687.2018.10.03.04.50.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 04:50:00 -0700 (PDT)
Subject: Re: [PATCH] mm: Avoid swapping in interrupt context
References: <1538387115-2363-1-git-send-email-amhetre@nvidia.com>
 <20181001122400.GF18290@dhcp22.suse.cz>
 <988dfe01-6553-1e0a-1d98-1b3d3aa67517@nvidia.com>
 <20181003110146.GB4714@dhcp22.suse.cz>
From: Ashish Mhetre <amhetre@nvidia.com>
Message-ID: <f54a61b2-b398-19e3-2b9b-1711ba3c75b7@nvidia.com>
Date: Wed, 3 Oct 2018 17:20:15 +0530
MIME-Version: 1.0
In-Reply-To: <20181003110146.GB4714@dhcp22.suse.cz>
Content-Type: multipart/alternative;
	boundary="------------8059928B8CB39DA3F9FE4505"
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, vdumpa@nvidia.com, Snikam@nvidia.com

--------------8059928B8CB39DA3F9FE4505
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit

>This doesn't show the backtrace part which contains the allocation
AFAICS.

My bad. Here is a complete dump:
[ 264.082531] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP ARM
[ 264.088350] Modules linked in:
[ 264.091406] CPU: 0 PID: 3805 Comm: kworker/0:4 Tainted: G W 
3.10.33-g990282b #1
[ 264.099572] Workqueue: events netstat_work_func
[ 264.104097] task: e7b12040 ti: dc7d4000 task.ti: dc7d4000
[ 264.109485] PC is at zs_map_object+0x180/0x18c
[ 264.113918] LR is at zram_bvec_rw.isra.15+0x304/0x88c
[ 264.118956] pc : [<c01581e8>] lr : [<c0456618>] psr: 200f0013
[ 264.118956] sp : dc7d5460 ip : fff00814 fp : 00000002
[ 264.130407] r10: ea8ec000 r9 : ebc93340 r8 : 00000000
[ 264.135618] r7 : c191502c r6 : dc7d4020 r5 : d25f5684 r4 : ec3158c0
[ 264.142128] r3 : 00000200 r2 : 00000002 r1 : c191502c r0 : ea8ec000

--------
[ 265.772426] [<c01581e8>] (zs_map_object+0x180/0x18c) from [<c0456618>] 
(zram_bvec_rw.isra.15+0x304/0x88c)
[ 265.781973] [<c0456618>] (zram_bvec_rw.isra.15+0x304/0x88c) from 
[<c0456d78>] (zram_make_request+0x1d8/0x378)
[ 265.791868] [<c0456d78>] (zram_make_request+0x1d8/0x378) from 
[<c02c7afc>] (generic_make_request+0xb0/0xdc)
[ 265.801588] [<c02c7afc>] (generic_make_request+0xb0/0xdc) from 
[<c02c7bb0>] (submit_bio+0x88/0x140)
[ 265.810617] [<c02c7bb0>] (submit_bio+0x88/0x140) from [<c01459d4>] 
(__swap_writepage+0x198/0x230)
[ 265.819471] [<c01459d4>] (__swap_writepage+0x198/0x230) from 
[<c011fc50>] (shrink_page_list+0x4e0/0x974)
[ 265.828930] [<c011fc50>] (shrink_page_list+0x4e0/0x974) from 
[<c0120644>] (shrink_inactive_list+0x150/0x3c8)
[ 265.838736] [<c0120644>] (shrink_inactive_list+0x150/0x3c8) from 
[<c0120de8>] (shrink_lruvec+0x20c/0x448)
[ 265.848282] [<c0120de8>] (shrink_lruvec+0x20c/0x448) from [<c012109c>] 
(shrink_zone+0x78/0x188)
[ 265.856960] [<c012109c>] (shrink_zone+0x78/0x188) from [<c01212ac>] 
(do_try_to_free_pages+0x100/0x544)
[ 265.866246] [<c01212ac>] (do_try_to_free_pages+0x100/0x544) from 
[<c0121928>] (try_to_free_pages+0x238/0x428)
[ 265.876140] [<c0121928>] (try_to_free_pages+0x238/0x428) from 
[<c01179cc>] (__alloc_pages_nodemask+0x5b0/0x90c)
[ 265.886207] [<c01179cc>] (__alloc_pages_nodemask+0x5b0/0x90c) from 
[<c0117d44>] (__get_free_pages+0x1c/0x34)
[ 265.896014] [<c0117d44>] (__get_free_pages+0x1c/0x34) from 
[<c0844a4c>] (tcp4_seq_show+0x248/0x4b4)
[ 265.905042] [<c0844a4c>] (tcp4_seq_show+0x248/0x4b4) from [<c017a844>] 
(seq_read+0x1e4/0x484)
[ 265.913550] [<c017a844>] (seq_read+0x1e4/0x484) from [<c01a84f0>] 
(proc_reg_read+0x60/0x88)
[ 265.921884] [<c01a84f0>] (proc_reg_read+0x60/0x88) from [<c015aa44>] 
(vfs_read+0xa0/0x14c)
[ 265.930129] [<c015aa44>] (vfs_read+0xa0/0x14c) from [<c015b0c4>] 
(SyS_read+0x44/0x80)
[ 265.937942] [<c015b0c4>] (SyS_read+0x44/0x80) from [<c052e98c>] 
(netstat_work_func+0x54/0xec)
[ 265.946450] [<c052e98c>] (netstat_work_func+0x54/0xec) from 
[<c0086700>] (process_one_work+0x13c/0x454)
[ 265.955823] [<c0086700>] (process_one_work+0x13c/0x454) from 
[<c008745c>] (worker_thread+0x140/0x3dc)
265.965022] [<c008745c>] (worker_thread+0x140/0x3dc) from [<c008cf4c>] 
(kthread+0xe0/0xe4)
[ 265.973269] [<c008cf4c>] (kthread+0xe0/0xe4) from [<c000ef98>] 
(ret_from_fork+0x14/0x20)
[ 264.148640] Flags: nzCv IRQs on FIQs on Mode SVC_32 ISA ARM Segment kernel
[ 264.155930] Control: 30c5387d Table: aaf7c000 DAC: fffffffd

On Wednesday 03 October 2018 04:31 PM, Michal Hocko wrote:
> On Wed 03-10-18 16:18:37, Ashish Mhetre wrote:
>>> How? No allocation request from the interrupt context can use a
>>> sleepable allocation context and that means that no reclaim is allowed
>>> from the IRQ context.
>> Kernel Oops happened when ZRAM was used as swap with zsmalloc as alloctor
>> under memory pressure condition.
>> This is probably because of kmalloc() from IRQ as pointed out by Sergey.
> Yes most likely and that should be fixed.
>   
>>> Could you provide the Oops message?
>> BUG_ON() got triggered at https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/tree/mm/zsmalloc.c?h=next-20181002#n1324 with Oops message:
>> [ 264.082531] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP ARM
>> [ 264.088350] Modules linked in:
>> [ 264.091406] CPU: 0 PID: 3805 Comm: kworker/0:4 Tainted: G W
>> 3.10.33-g990282b #1
>> [ 264.099572] Workqueue: events netstat_work_func
>> [ 264.104097] task: e7b12040 ti: dc7d4000 task.ti: dc7d4000
>> [ 264.109485] PC is at zs_map_object+0x180/0x18c
>> [ 264.113918] LR is at zram_bvec_rw.isra.15+0x304/0x88c
>> [ 264.118956] pc : [<c01581e8>] lr : [<c0456618>] psr: 200f0013
>> [ 264.118956] sp : dc7d5460 ip : fff00814 fp : 00000002
>> [ 264.130407] r10: ea8ec000 r9 : ebc93340 r8 : 00000000
>> [ 264.135618] r7 : c191502c r6 : dc7d4020 r5 : d25f5684 r4 : ec3158c0
>> [ 264.142128] r3 : 00000200 r2 : 00000002 r1 : c191502c r0 : ea8ec000
> This doesn't show the backtrace part which contains the allocation
> AFAICS.


--------------8059928B8CB39DA3F9FE4505
Content-Type: text/html; charset="utf-8"
Content-Transfer-Encoding: 8bit

<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  </head>
  <body text="#000000" bgcolor="#FFFFFF">
    <pre wrap="">&gt;This doesn't show the backtrace part which contains the allocation
AFAICS.

My bad. Here is a complete dump:
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 264.082531] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP ARM<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 264.088350] Modules linked in:<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 264.091406] CPU: 0 PID: 3805 Comm: kworker/0:4 Tainted: G W 3.10.33-g990282b #1<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 264.099572] Workqueue: events netstat_work_func<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 264.104097] task: e7b12040 ti: dc7d4000 task.ti: dc7d4000<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 264.109485] PC is at zs_map_object+0x180/0x18c<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 264.113918] LR is at zram_bvec_rw.isra.15+0x304/0x88c<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 264.118956] pc : [&lt;c01581e8&gt;] lr : [&lt;c0456618&gt;] psr: 200f0013<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 264.118956] sp : dc7d5460 ip : fff00814 fp : 00000002<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 264.130407] r10: ea8ec000 r9 : ebc93340 r8 : 00000000<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 264.135618] r7 : c191502c r6 : dc7d4020 r5 : d25f5684 r4 : ec3158c0<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 264.142128] r3 : 00000200 r2 : 00000002 r1 : c191502c r0 : ea8ec000<span>A </span></span>

<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">--------<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 265.772426] [&lt;c01581e8&gt;] (zs_map_object+0x180/0x18c) from [&lt;c0456618&gt;] (zram_bvec_rw.isra.15+0x304/0x88c)<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 265.781973] [&lt;c0456618&gt;] (zram_bvec_rw.isra.15+0x304/0x88c) from [&lt;c0456d78&gt;] (zram_make_request+0x1d8/0x378)<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 265.791868] [&lt;c0456d78&gt;] (zram_make_request+0x1d8/0x378) from [&lt;c02c7afc&gt;] (generic_make_request+0xb0/0xdc)<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 265.801588] [&lt;c02c7afc&gt;] (generic_make_request+0xb0/0xdc) from [&lt;c02c7bb0&gt;] (submit_bio+0x88/0x140)<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 265.810617] [&lt;c02c7bb0&gt;] (submit_bio+0x88/0x140) from [&lt;c01459d4&gt;] (__swap_writepage+0x198/0x230)<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 265.819471] [&lt;c01459d4&gt;] (__swap_writepage+0x198/0x230) from [&lt;c011fc50&gt;] (shrink_page_list+0x4e0/0x974)<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 265.828930] [&lt;c011fc50&gt;] (shrink_page_list+0x4e0/0x974) from [&lt;c0120644&gt;] (shrink_inactive_list+0x150/0x3c8)<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 265.838736] [&lt;c0120644&gt;] (shrink_inactive_list+0x150/0x3c8) from [&lt;c0120de8&gt;] (shrink_lruvec+0x20c/0x448)<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 265.848282] [&lt;c0120de8&gt;] (shrink_lruvec+0x20c/0x448) from [&lt;c012109c&gt;] (shrink_zone+0x78/0x188)<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 265.856960] [&lt;c012109c&gt;] (shrink_zone+0x78/0x188) from [&lt;c01212ac&gt;] (do_try_to_free_pages+0x100/0x544)<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 265.866246] [&lt;c01212ac&gt;] (do_try_to_free_pages+0x100/0x544) from [&lt;c0121928&gt;] (try_to_free_pages+0x238/0x428)<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 265.876140] [&lt;c0121928&gt;] (try_to_free_pages+0x238/0x428) from [&lt;c01179cc&gt;] (__alloc_pages_nodemask+0x5b0/0x90c)<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 265.886207] [&lt;c01179cc&gt;] (__alloc_pages_nodemask+0x5b0/0x90c) from [&lt;c0117d44&gt;] (__get_free_pages+0x1c/0x34)<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 265.896014] [&lt;c0117d44&gt;] (__get_free_pages+0x1c/0x34) from [&lt;c0844a4c&gt;] (tcp4_seq_show+0x248/0x4b4)<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 265.905042] [&lt;c0844a4c&gt;] (tcp4_seq_show+0x248/0x4b4) from [&lt;c017a844&gt;] (seq_read+0x1e4/0x484)<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 265.913550] [&lt;c017a844&gt;] (seq_read+0x1e4/0x484) from [&lt;c01a84f0&gt;] (proc_reg_read+0x60/0x88)<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 265.921884] [&lt;c01a84f0&gt;] (proc_reg_read+0x60/0x88) from [&lt;c015aa44&gt;] (vfs_read+0xa0/0x14c)<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 265.930129] [&lt;c015aa44&gt;] (vfs_read+0xa0/0x14c) from [&lt;c015b0c4&gt;] (SyS_read+0x44/0x80)<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 265.937942] [&lt;c015b0c4&gt;] (SyS_read+0x44/0x80) from [&lt;c052e98c&gt;] (netstat_work_func+0x54/0xec)<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 265.946450] [&lt;c052e98c&gt;] (netstat_work_func+0x54/0xec) from [&lt;c0086700&gt;] (process_one_work+0x13c/0x454)<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 265.955823] [&lt;c0086700&gt;] (process_one_work+0x13c/0x454) from [&lt;c008745c&gt;] (worker_thread+0x140/0x3dc)<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">265.965022] [&lt;c008745c&gt;] (worker_thread+0x140/0x3dc) from [&lt;c008cf4c&gt;] (kthread+0xe0/0xe4)<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 265.973269] [&lt;c008cf4c&gt;] (kthread+0xe0/0xe4) from [&lt;c000ef98&gt;] (ret_from_fork+0x14/0x20)<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 264.148640] Flags: nzCv IRQs on FIQs on Mode SVC_32 ISA ARM Segment kernel<span>A </span></span>
<span style="color: rgb(0, 0, 0); font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 13px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: start; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">[ 264.155930] Control: 30c5387d Table: aaf7c000 DAC: fffffffd<span> 
</span></span></pre>
    <div class="moz-cite-prefix">On Wednesday 03 October 2018 04:31 PM,
      Michal Hocko wrote:<br>
    </div>
    <blockquote type="cite"
      cite="mid:20181003110146.GB4714@dhcp22.suse.cz">
      <pre wrap="">On Wed 03-10-18 16:18:37, Ashish Mhetre wrote:
</pre>
      <blockquote type="cite">
        <blockquote type="cite">
          <pre wrap="">How? No allocation request from the interrupt context can use a
sleepable allocation context and that means that no reclaim is allowed
from the IRQ context.
</pre>
        </blockquote>
        <pre wrap="">Kernel Oops happened when ZRAM was used as swap with zsmalloc as alloctor
under memory pressure condition.
This is probably because of kmalloc() from IRQ as pointed out by Sergey.
</pre>
      </blockquote>
      <pre wrap="">
Yes most likely and that should be fixed.
 
</pre>
      <blockquote type="cite">
        <blockquote type="cite">
          <pre wrap="">Could you provide the Oops message?
</pre>
        </blockquote>
        <pre wrap="">BUG_ON() got triggered at <a class="moz-txt-link-freetext" href="https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/tree/mm/zsmalloc.c?h=next-20181002#n1324">https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/tree/mm/zsmalloc.c?h=next-20181002#n1324</a> with Oops message:
[ 264.082531] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP ARM
[ 264.088350] Modules linked in:
[ 264.091406] CPU: 0 PID: 3805 Comm: kworker/0:4 Tainted: G W
3.10.33-g990282b #1
[ 264.099572] Workqueue: events netstat_work_func
[ 264.104097] task: e7b12040 ti: dc7d4000 task.ti: dc7d4000
[ 264.109485] PC is at zs_map_object+0x180/0x18c
[ 264.113918] LR is at zram_bvec_rw.isra.15+0x304/0x88c
[ 264.118956] pc : [&lt;c01581e8&gt;] lr : [&lt;c0456618&gt;] psr: 200f0013
[ 264.118956] sp : dc7d5460 ip : fff00814 fp : 00000002
[ 264.130407] r10: ea8ec000 r9 : ebc93340 r8 : 00000000
[ 264.135618] r7 : c191502c r6 : dc7d4020 r5 : d25f5684 r4 : ec3158c0
[ 264.142128] r3 : 00000200 r2 : 00000002 r1 : c191502c r0 : ea8ec000
</pre>
      </blockquote>
      <pre wrap="">
This doesn't show the backtrace part which contains the allocation
AFAICS.
</pre>
    </blockquote>
    <br>
  </body>
</html>

--------------8059928B8CB39DA3F9FE4505--
