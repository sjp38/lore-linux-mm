Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id AE8BE8D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 22:33:43 -0400 (EDT)
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to
 expand_upwards
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <alpine.DEB.2.00.1104191657030.26867@router.home>
References: <20110415135144.GE8828@tiehlicka.suse.cz>
	 <alpine.LSU.2.00.1104171952040.22679@sister.anvils>
	 <20110418100131.GD8925@tiehlicka.suse.cz>
	 <20110418135637.5baac204.akpm@linux-foundation.org>
	 <20110419111004.GE21689@tiehlicka.suse.cz>
	 <1303228009.3171.18.camel@mulgrave.site>
	 <BANLkTimYrD_Sby_u-fPSwn-RJJyEVavU5w@mail.gmail.com>
	 <1303233088.3171.26.camel@mulgrave.site>
	 <alpine.DEB.2.00.1104191213120.17888@router.home>
	 <1303235306.3171.33.camel@mulgrave.site>
	 <alpine.DEB.2.00.1104191254300.19358@router.home>
	 <1303237217.3171.39.camel@mulgrave.site>
	 <alpine.DEB.2.00.1104191325470.19358@router.home>
	 <1303242580.11237.10.camel@mulgrave.site>
	 <alpine.DEB.2.00.1104191530040.23077@router.home>
	 <1303248103.11237.16.camel@mulgrave.site>
	 <alpine.DEB.2.00.1104191627040.23077@router.home>
	 <1303249716.11237.26.camel@mulgrave.site>
	 <alpine.DEB.2.00.1104191657030.26867@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 19 Apr 2011 21:33:37 -0500
Message-ID: <1303266817.11237.37.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, David Rientjes <rientjes@google.com>

On Tue, 2011-04-19 at 16:58 -0500, Christoph Lameter wrote:
> On Tue, 19 Apr 2011, James Bottomley wrote:
> 
> > > Which part of me telling you that you will break lots of other things in
> > > the core kernel dont you get?
> >
> > I get that you tell me this ... however, the systems that, according to
> > you, should be failing to get to boot prompt do, in fact, manage it.
> 
> If you dont use certain subsystems then it may work. Also do you run with
> debuggin on.
> 
> The following patch is I think what would be needed to fix it.

Not really: crashes immediately on boot

[    0.000000] FP[0] enabled: Rev 1 Model 20
[    0.000000] The 64-bit Kernel has started...
[    0.000000] bootconsole [ttyB0] enabled
[    0.000000] Initialized PDC Console for debugging.
[    0.000000] Determining PDC firmware type: 64 bit PAT.
[    0.000000] model 00008870 00000491 00000000 00000002 3e0505e7352af710 100000f0 00000008 000000b2 000000b2
[    0.000000] vers  00000301
[    0.000000] CPUID vers 20 rev 4 (0x00000284)
[    0.000000] capabilities 0x35
[    0.000000] model 9000/800/rp3440  
[    0.000000] parisc_cache_init: Only equivalent aliasing supported!
[    0.000000] Memory Ranges:
[    0.000000]  0) Start 0x0000000000000000 End 0x000000003fffffff Size   1024 MB
[    0.000000]  1) Start 0x0000004040000000 End 0x000000407fdfffff Size   1022 MB
[    0.000000] Total Memory: 2046 MB
[    0.000000] initrd: 7f390000-7ffedf6d
[    0.000000] initrd: reserving 3f390000-3ffedf6d (mem_max 7fe00000)
[    0.000000] ------------[ cut here ]------------
[    0.000000] kernel BUG at mm/mm_init.c:127!
[    0.000000] 
[    0.000000]      YZrvWESTHLNXBCVMcbcbcbcbOGFRQPDI
[    0.000000] PSW: 00001000000001001111111100001110 Not tainted
[    0.000000] r00-03  000000ff0804ff0e 000000004076a640 0000000040798c50 0000004080000000
[    0.000000] r04-07  0000000040746e40 0000000004040000 0000000000000001 0000000040654150
[    0.000000] r08-11  00000000405bd540 000000000407fe00 0000000000000001 0000000000000000
[    0.000000] r12-15  00000000405bc740 000f000000000000 00000000000001ff 000000004076a640
[    0.000000] r16-19  00000000000000ff 0000000000000000 2000000000000000 0000000000000000
[    0.000000] r20-23  0000004080000000 00000000405bd908 0000000000000000 0000000004040000
[    0.000000] r24-27  0000000000000001 0000000000000000 0000004080000000 0000000040746e40
[    0.000000] r28-31  2000000000000000 00000000405b0610 00000000405b0640 0000000000000000
[    0.000000] sr00-03  0000000000000000 0000000000000000 0000000000000000 0000000000000000
[    0.000000] sr04-07  0000000000000000 0000000000000000 0000000000000000 0000000000000000
[    0.000000] 
[    0.000000] IASQ: 0000000000000000 0000000000000000 IAOQ: 0000000040798fac 0000000040798fb0
[    0.000000]  IIR: 03ffe01f    ISR: 0000000010350000  IOR: 0000010000000000
[    0.000000]  CPU:        0   CR30: 00000000405b0000 CR31: fffffff0f0e098e0
[    0.000000]  ORIG_R28: 000000000003fe00
[    0.000000]  IAOQ[0]: mminit_verify_page_links+0x84/0xa0
[    0.000000]  IAOQ[1]: mminit_verify_page_links+0x88/0xa0
[    0.000000]  RP(r2): memmap_init_zone+0x148/0x2a0
[    0.000000] Backtrace:
[    0.000000]  [<0000000040798c50>] memmap_init_zone+0x148/0x2a0
[    0.000000]  [<0000000040777ca8>] free_area_init_node+0x3c8/0x518
[    0.000000]  [<000000004076fde0>] paging_init+0x928/0xb20
[    0.000000]  [<0000000040770a48>] setup_arch+0xe8/0x120
[    0.000000]  [<000000004076c9a0>] start_kernel+0xf0/0x830
[    0.000000]  [<000000004011f4fc>] start_parisc+0xa4/0xb8
[    0.000000]  [<00000000404b0f0c>] packet_ioctl+0x1e4/0x208
[    0.000000]  [<00000000404a79d0>] unix_ioctl+0x70/0x168
[    0.000000]  [<0000000040482d24>] ip_mc_gsfget+0x14c/0x200
[    0.000000]  [<000000004046cc20>] raw_ioctl+0xe8/0x118
[    0.000000]  [<000000004044f524>] do_tcp_getsockopt+0x5c4/0x5d0
[    0.000000]  [<0000000040432d64>] netlink_getsockopt+0x15c/0x178
[    0.000000] 
[    0.000000] Backtrace:
[    0.000000]  [<000000004011f984>] show_stack+0x14/0x20
[    0.000000]  [<000000004011f9a8>] dump_stack+0x18/0x28
[    0.000000]  [<000000004012022c>] die_if_kernel+0x194/0x258
[    0.000000]  [<0000000040120b30>] handle_interruption+0x840/0x8f8
[    0.000000]  [<0000000040798fac>] mminit_verify_page_links+0x84/0xa0
[    0.000000] 
[    0.000000] ---[ end trace 139ce121c98e96c9 ]---
[    0.000000] Kernel panic - not syncing: Attempted to kill the idle task!
[    0.000000] Backtrace:
[    0.000000]  [<000000004011f984>] show_stack+0x14/0x20
[    0.000000]  [<000000004011f9a8>] dump_stack+0x18/0x28
[    0.000000]  [<000000004015945c>] panic+0xd4/0x368
[    0.000000]  [<000000004015f054>] do_exit+0x89c/0x9d8
[    0.000000]  [<00000000401202d4>] die_if_kernel+0x23c/0x258
[    0.000000]  [<0000000040120b30>] handle_interruption+0x840/0x8f8
[    0.000000]  [<0000000040798fac>] mminit_verify_page_links+0x84/0xa0
[    0.000000] 

There's a lot more to discontigmem than just page_to_nid ... there's the
whole pfn_to_nid() thing as well

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
