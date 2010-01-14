Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id BF1666B006A
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 09:08:38 -0500 (EST)
Date: Thu, 14 Jan 2010 22:08:15 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [ RESEND PATCH v3] Memory-Hotplug: Fix the bug on interface
	/dev/mem for 64-bit kernel
Message-ID: <20100114140815.GA18580@localhost>
References: <DA586906BA1FFC4384FCFD6429ECE860316C0133@shzsmsx502.ccr.corp.intel.com> <20100112170433.394be31b.kamezawa.hiroyu@jp.fujitsu.com> <20100114132451.GA2546@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100114132451.GA2546@localhost>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "Zheng, Shaohui" <shaohui.zheng@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "ak@linux.intel.com" <ak@linux.intel.com>, "y-goto@jp.fujitsu.com" <y-goto@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, "x86@kernel.org" <x86@kernel.org>
List-ID: <linux-mm.kvack.org>

> > 2. pgdat->[start,end], totalram_pages etc...are updated at memory hotplug.
> >    Please place the hook nearby them.
> 
> arch/x86/mm/init_64.c:arch_add_memory() updates max_pfn_mapped, in
> this sense it's equally OK to update max_pfn/max_low_pfn etc before
> the call to arch_add_memory() ;)

Shaohui, I'd suggest to update max_pfn/max_low_pfn/high_memory in
arch/x86/mm/init_64.c:arch_add_memory() now, for X86_64.

Later on we can add code to arch/x86/mm/init_32.c:arch_add_memory()
for X86_32.

The code cannot be shared anyway.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
