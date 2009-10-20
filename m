Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 64BFB6B004F
	for <linux-mm@kvack.org>; Mon, 19 Oct 2009 21:47:09 -0400 (EDT)
Received: by bwz7 with SMTP id 7so87751bwz.6
        for <linux-mm@kvack.org>; Mon, 19 Oct 2009 18:47:06 -0700 (PDT)
Date: Tue, 20 Oct 2009 03:47:03 +0200
From: Karol Lewandowski <karol.k.lewandowski@gmail.com>
Subject: Re: [Bug #14141] order 2 page allocation failures (generic)
Message-ID: <20091020014703.GA5329@bizet.domek.prywatny>
References: <3onW63eFtRF.A.xXH.oMTxKB@chimera> <200910190133.33183.elendil@planet.nl> <1255912562.6824.9.camel@penberg-laptop> <200910190444.55867.elendil@planet.nl> <alpine.DEB.2.00.0910191146110.1306@sebohet.brgvxre.pu> <1255946051.5941.2.camel@penberg-laptop> <20091019140145.GA4222@bizet.domek.prywatny> <20091019140619.GD9036@csn.ul.ie> <20091019170947.GA3782@bizet.domek.prywatny>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091019170947.GA3782@bizet.domek.prywatny>
Sender: owner-linux-mm@kvack.org
To: Karol Lewandowski <karol.k.lewandowski@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Pekka Enberg <penberg@cs.helsinki.fi>, Tobi Oetiker <tobi@oetiker.ch>, Frans Pop <elendil@planet.nl>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Reinette Chatre <reinette.chatre@intel.com>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Mohamed Abbas <mohamed.abbas@intel.com>, "John W. Linville" <linville@tuxdriver.com>, linux-mm@kvack.org, jens.axboe@oracle.com
List-ID: <linux-mm.kvack.org>

On Mon, Oct 19, 2009 at 07:09:47PM +0200, Karol Lewandowski wrote:
> On Mon, Oct 19, 2009 at 03:06:19PM +0100, Mel Gorman wrote:
> > Can you test with my kswapd patch applied and commits 373c0a7e,8aa7e847
> > reverted please?
> 
> It seems that your patch and Frans' reverts together *do* make
> difference.
> 
> With these patches I haven't been able to trigger failures so far
> (in about 6 attempts). I'll continue testing and let you know if
> anything changes.

Damn it.

I'm sorry to inform you that yes, I still get failures (less often,
but still).

Thanks.


e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
e100: Copyright(c) 1999-2006 Intel Corporation
e100 0000:00:03.0: PCI INT A -> Link[LNKC] -> GSI 9 (level, low) -> IRQ 9
e100 0000:00:03.0: PME# disabled
e100: eth0: e100_probe: addr 0xe8120000, irq 9, MAC addr 00:10:a4:89:e8:84
ifconfig: page allocation failure. order:5, mode:0x8020
Pid: 5151, comm: ifconfig Not tainted 2.6.31+frans2+mel-00002-g90702f9-dirty #2
Call Trace:
 [<c015c4e1>] ? __alloc_pages_nodemask+0x423/0x468
 [<c0104de7>] ? dma_generic_alloc_coherent+0x4a/0xab
 [<c0104d9d>] ? dma_generic_alloc_coherent+0x0/0xab
 [<d1614b6f>] ? e100_alloc_cbs+0xc7/0x174 [e100]
 [<d1615bfe>] ? e100_up+0x1b/0xf5 [e100]
 [<d1615cef>] ? e100_open+0x17/0x41 [e100]
 [<c02f871f>] ? dev_open+0x8f/0xc5
 [<c02f7ed9>] ? dev_change_flags+0xa2/0x155
 [<c032daa6>] ? devinet_ioctl+0x22a/0x51c
 [<c02ebabe>] ? sock_ioctl+0x0/0x1e4
 [<c02ebc7e>] ? sock_ioctl+0x1c0/0x1e4
 [<c02ebabe>] ? sock_ioctl+0x0/0x1e4
 [<c017f23a>] ? vfs_ioctl+0x16/0x4a
 [<c017fb01>] ? do_vfs_ioctl+0x48a/0x4c1
 [<c0168137>] ? handle_mm_fault+0x1e0/0x42c
 [<c0348c6b>] ? do_page_fault+0x2ce/0x2e4
 [<c017fb64>] ? sys_ioctl+0x2c/0x42
 [<c0102748>] ? sysenter_do_call+0x12/0x26
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
Normal per-cpu:
CPU    0: hi:   90, btch:  15 usd:  35
Active_anon:14778 active_file:10836 inactive_anon:22033
 inactive_file:11854 unevictable:0 dirty:6 writeback:0 unstable:0
 free:1031 slab:2083 mapped:6193 pagetables:417 bounce:0
DMA free:1096kB min:124kB low:152kB high:184kB active_anon:528kB inactive_anon:3440kB active_file:1076kB inactive_file:5580kB unevictable:0kB present:15868kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 238 238
Normal free:3028kB min:1908kB low:2384kB high:2860kB active_anon:58584kB inactive_anon:84692kB active_file:42268kB inactive_file:41836kB unevictable:0kB present:243776kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 46*4kB 0*8kB 5*16kB 0*32kB 1*64kB 0*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 1096kB
Normal: 135*4kB 213*8kB 21*16kB 4*32kB 5*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 3028kB
25927 total pagecache pages
3010 pages in swap cache
Swap cache stats: add 205613, delete 202603, find 63665/79800
Free swap  = 485236kB
Total swap = 514040kB
65520 pages RAM
1663 pages reserved
14633 pages shared
52919 pages non-shared
ifconfig: page allocation failure. order:5, mode:0x8020
Pid: 5151, comm: ifconfig Not tainted 2.6.31+frans2+mel-00002-g90702f9-dirty #2
Call Trace:
 [<c015c4e1>] ? __alloc_pages_nodemask+0x423/0x468
 [<c0104de7>] ? dma_generic_alloc_coherent+0x4a/0xab
 [<c0104d9d>] ? dma_generic_alloc_coherent+0x0/0xab
 [<d1614b6f>] ? e100_alloc_cbs+0xc7/0x174 [e100]
 [<d1615bfe>] ? e100_up+0x1b/0xf5 [e100]
 [<d1615cef>] ? e100_open+0x17/0x41 [e100]
 [<c02f871f>] ? dev_open+0x8f/0xc5
 [<c02f7ed9>] ? dev_change_flags+0xa2/0x155
 [<c032daa6>] ? devinet_ioctl+0x22a/0x51c
 [<c02ebabe>] ? sock_ioctl+0x0/0x1e4
 [<c02ebc7e>] ? sock_ioctl+0x1c0/0x1e4
 [<c02ebabe>] ? sock_ioctl+0x0/0x1e4
 [<c017f23a>] ? vfs_ioctl+0x16/0x4a
 [<c017fb01>] ? do_vfs_ioctl+0x48a/0x4c1
 [<c0175fd1>] ? vfs_write+0xf4/0x105
 [<c017fb64>] ? sys_ioctl+0x2c/0x42
 [<c0102748>] ? sysenter_do_call+0x12/0x26
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
Normal per-cpu:
CPU    0: hi:   90, btch:  15 usd:  67
Active_anon:14760 active_file:10798 inactive_anon:22052
 inactive_file:11862 unevictable:0 dirty:6 writeback:30 unstable:0
 free:1031 slab:2083 mapped:6187 pagetables:417 bounce:0
DMA free:1096kB min:124kB low:152kB high:184kB active_anon:528kB inactive_anon:3440kB active_file:1076kB inactive_file:5580kB unevictable:0kB present:15868kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 238 238
Normal free:3028kB min:1908kB low:2384kB high:2860kB active_anon:58512kB inactive_anon:84768kB active_file:42116kB inactive_file:41868kB unevictable:0kB present:243776kB pages_scanned:100 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 46*4kB 0*8kB 5*16kB 0*32kB 1*64kB 0*128kB 1*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 1096kB
Normal: 135*4kB 213*8kB 21*16kB 4*32kB 5*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 3028kB
25924 total pagecache pages
3037 pages in swap cache
Swap cache stats: add 205644, delete 202607, find 63666/79802
Free swap  = 485116kB
Total swap = 514040kB
65520 pages RAM
1663 pages reserved
14638 pages shared
52896 pages non-shared
e100 0000:00:03.0: firmware: requesting e100/d101s_ucode.bin
ADDRCONF(NETDEV_UP): eth0: link is not ready
e100: eth0 NIC Link is Up 100 Mbps Full Duplex
ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
eth0: no IPv6 routers present

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
