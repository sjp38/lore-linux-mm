Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 87BDD6B0071
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 21:42:23 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0C2gKE1014337
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 12 Jan 2010 11:42:20 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B3CA45DE7A
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 11:42:18 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F12AE45DE6F
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 11:42:17 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 75ACAE18007
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 11:42:17 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id AB8BCE18003
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 11:42:15 +0900 (JST)
Date: Tue, 12 Jan 2010 11:39:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH - resend] Memory-Hotplug: Fix the bug on interface
 /dev/mem for 64-bit kernel(v1)
Message-Id: <20100112113903.89163c46.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100112023307.GA16661@localhost>
References: <DA586906BA1FFC4384FCFD6429ECE86031560BAC@shzsmsx502.ccr.corp.intel.com>
	<20100108124851.GB6153@localhost>
	<DA586906BA1FFC4384FCFD6429ECE86031560FC1@shzsmsx502.ccr.corp.intel.com>
	<20100111124303.GA21408@localhost>
	<20100112093031.0fc6877f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100112023307.GA16661@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "Zheng, Shaohui" <shaohui.zheng@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "ak@linux.intel.com" <ak@linux.intel.com>, "y-goto@jp.fujitsu.com" <y-goto@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, "x86@kernel.org" <x86@kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 12 Jan 2010 10:33:08 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> Sure, here it is :)
> ---
> x86: use the generic page_is_ram()
> 
> The generic resource based page_is_ram() works better with memory
> hotplug/hotremove. So switch the x86 e820map based code to it.
> 
> CC: Andi Kleen <andi@firstfloor.org> 
> CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> 
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

Ack.


> +#ifdef CONFIG_X86
> +	/*
> +	 * A special case is the first 4Kb of memory;
> +	 * This is a BIOS owned area, not kernel ram, but generally
> +	 * not listed as such in the E820 table.
> +	 */
> +	if (pfn == 0)
> +		return 0;
> +
> +	/*
> +	 * Second special case: Some BIOSen report the PC BIOS
> +	 * area (640->1Mb) as ram even though it is not.
> +	 */
> +	if (pfn >= (BIOS_BEGIN >> PAGE_SHIFT) &&
> +	    pfn <  (BIOS_END   >> PAGE_SHIFT))
> +		return 0;
> +#endif

I'm glad if this part is sorted out in clean way ;)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
