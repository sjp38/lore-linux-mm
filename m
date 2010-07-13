Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id BE3F46B02A3
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 03:39:08 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6D7d6ow028299
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 13 Jul 2010 16:39:06 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A61245DE52
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 16:39:06 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0CD4D45DE53
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 16:39:06 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id EBE2C1DB8038
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 16:39:05 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9CEBC1DB8043
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 16:39:02 +0900 (JST)
Date: Tue, 13 Jul 2010 16:34:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] Tight check of pfn_valid on sparsemem
Message-Id: <20100713163417.17895202.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100713072009.GA19839@n2100.arm.linux.org.uk>
References: <20100712155348.GA2815@barrios-desktop>
	<20100713121947.612bd656.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTiny7dz8ssDknI7y4JFcVP9SV1aNM7f0YMUxafv7@mail.gmail.com>
	<20100713132312.a7dfb100.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTinVwmo5pemz86nXaQT3V_ujaPLOsyNeQIFhL0Vu@mail.gmail.com>
	<20100713072009.GA19839@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Minchan Kim <minchan.kim@gmail.com>, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, Yakui Zhao <yakui.zhao@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, arm-kernel@lists.infradead.org, kgene.kim@samsung.com, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Tue, 13 Jul 2010 08:20:09 +0100
Russell King - ARM Linux <linux@arm.linux.org.uk> wrote:

> On Tue, Jul 13, 2010 at 03:04:00PM +0900, Minchan Kim wrote:
> > > __get_user() works with TLB and page table, the vaddr is really mapped or not.
> > > If you got SEGV, __get_user() returns -EFAULT. It works per page granule.
> 
> Not in kernel space.  It works on 1MB sections there.
> 
> Testing whether a page is mapped by __get_user is a hugely expensive
> way to test whether a PFN is valid.

Note: pfn_valid() is for checking "there is memmap". 

> It'd be cheaper to use our flatmem implementation of pfn_valid() instead.
> 
Hmm. IIUC, pfn_valid() succeeds in almost all case if there is a section.
But yes, I'm not familar with ARM. 

I love another idea as I've already shown as preparing _a_ page filled with
0x00004000 and map it into the all holes. PG_reserved will help almost all case
even if it's ugly.

Anyway, sparsemem is designed to be aligned to SECTION_SIZE of memmap.
Please avoid adding new Spaghetti code without proper configs.
Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
