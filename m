Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6A9B66B02A4
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 04:07:18 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6D87EZl008877
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 13 Jul 2010 17:07:14 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 72E5B45DE6F
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 17:07:14 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E76045DE60
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 17:07:14 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 33D481DB803E
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 17:07:14 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E1C211DB8037
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 17:07:10 +0900 (JST)
Date: Tue, 13 Jul 2010 17:02:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] Tight check of pfn_valid on sparsemem
Message-Id: <20100713170222.9369e649.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100713165808.e340e6dc.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100712155348.GA2815@barrios-desktop>
	<20100713121947.612bd656.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTiny7dz8ssDknI7y4JFcVP9SV1aNM7f0YMUxafv7@mail.gmail.com>
	<20100713132312.a7dfb100.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTinVwmo5pemz86nXaQT3V_ujaPLOsyNeQIFhL0Vu@mail.gmail.com>
	<20100713072009.GA19839@n2100.arm.linux.org.uk>
	<20100713163417.17895202.kamezawa.hiroyu@jp.fujitsu.com>
	<20100713165808.e340e6dc.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, Minchan Kim <minchan.kim@gmail.com>, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, Yakui Zhao <yakui.zhao@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, arm-kernel@lists.infradead.org, kgene.kim@samsung.com, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Tue, 13 Jul 2010 16:58:08 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Tue, 13 Jul 2010 16:34:17 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > Anyway, sparsemem is designed to be aligned to SECTION_SIZE of memmap.
> > Please avoid adding new Spaghetti code without proper configs.
> > Thanks,
> 
> Ok, I realized I misunderstand all. Arm doesn't unmap memmap but reuse the page
> for memmap without modifing ptes. My routine only works when ARM uses sparsemem_vmemmap.
> But yes, it isn't.
> 
> Hmm...How about using pfn_valid() for FLATMEM or avoid using SPARSEMEM ?
> If you want conrols lower than SPARSEMEM, FLATMEM works better because ARM unmaps memmap.
                      allocation of memmap in lower granule than SPARSEMEM.


How about stop using SPARSEMEM ? What's the benefit ? It just eats up memory for
mem_section[].

Sorry,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
