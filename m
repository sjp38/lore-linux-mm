Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8C8866B006A
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 20:02:23 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0C12GCj005218
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 12 Jan 2010 10:02:18 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 31E0145DE55
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 10:02:18 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 113F845DE4F
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 10:02:18 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D98231DB8042
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 10:02:17 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 97C4C1DB803E
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 10:02:17 +0900 (JST)
Date: Tue, 12 Jan 2010 09:58:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH - resend] Memory-Hotplug: Fix the bug on interface
 /dev/mem for 64-bit kernel(v1)
Message-Id: <20100112095848.b2cee1f3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4B478BEA.1010504@linux.intel.com>
References: <DA586906BA1FFC4384FCFD6429ECE86031560BAC@shzsmsx502.ccr.corp.intel.com>
	<4B46BC6F.5060607@kernel.org>
	<4B478BEA.1010504@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <ak@linux.intel.com>
Cc: "H. Peter Anvin" <hpa@kernel.org>, "Zheng, Shaohui" <shaohui.zheng@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "y-goto@jp.fujitsu.com" <y-goto@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, "x86@kernel.org" <x86@kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 08 Jan 2010 20:47:54 +0100
Andi Kleen <ak@linux.intel.com> wrote:

> H. Peter Anvin wrote:
> > On 01/07/2010 07:32 PM, Zheng, Shaohui wrote:
> >> Resend the patch to the mailing-list, the original patch URL is 
> >> http://patchwork.kernel.org/patch/69075/, it is not accepted without comments,
> >> sent it again to review.
> >>
> >> Memory-Hotplug: Fix the bug on interface /dev/mem for 64-bit kernel
> >>
> >> The new added memory can not be access by interface /dev/mem, because we do not
> >>  update the variable high_memory. This patch add a new e820 entry in e820 table,
> >>  and update max_pfn, max_low_pfn and high_memory.
> >>
> >> We add a function update_pfn in file arch/x86/mm/init.c to udpate these
> >>  varibles. Memory hotplug does not make sense on 32-bit kernel, so we did not
> >>  concern it in this function.
> >>
> > 
> > Memory hotplug makes sense on 32-bit kernels, at least in virtual
> > environments.
> 
> No VM currently supports it to my knowledge. They all use traditional
> balooning.
> 
> If someone adds that they can still fix it, but right now fixing it on 64bit
> is the important part.
> 
I wonder...with some modification, memory hotplug (or Mel's page coalescing)
can be used for balloning in MAX_ORDER page size.
I'm sorry if VM' baloon drivers has no fragmentaion problem.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
