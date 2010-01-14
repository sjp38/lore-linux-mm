Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3B4766B006A
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 08:58:12 -0500 (EST)
Date: Thu, 14 Jan 2010 21:24:51 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [ RESEND PATCH v3] Memory-Hotplug: Fix the bug on interface
	/dev/mem for 64-bit kernel
Message-ID: <20100114132451.GA2546@localhost>
References: <DA586906BA1FFC4384FCFD6429ECE860316C0133@shzsmsx502.ccr.corp.intel.com> <20100112170433.394be31b.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100112170433.394be31b.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "Zheng, Shaohui" <shaohui.zheng@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "ak@linux.intel.com" <ak@linux.intel.com>, "y-goto@jp.fujitsu.com" <y-goto@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, "x86@kernel.org" <x86@kernel.org>
List-ID: <linux-mm.kvack.org>

Kame,

On Tue, Jan 12, 2010 at 05:04:33PM +0900, KAMEZAWA Hiroyuki wrote:

> 3 points...
> 1. I think this patch cannot be compiled in archs other than x86. Right ?
>    IOW, please add static inline dummy...

Good catch!

> 2. pgdat->[start,end], totalram_pages etc...are updated at memory hotplug.
>    Please place the hook nearby them.

arch/x86/mm/init_64.c:arch_add_memory() updates max_pfn_mapped, in
this sense it's equally OK to update max_pfn/max_low_pfn etc before
the call to arch_add_memory() ;)

> 3. I recommend you yo use memory hotplug notifier.
>    If it's allowed, it will be cleaner.

Hmm, notifier is for _outsider_ subsystems. It smells a bit
overkill to do notifier _inside_ the hotplug code.

>    It seems there are no strict ordering to update parameters this patch touches.

I tend to agree. That said, it does help keep our mind straight if we do it
in some logical order: max_pfn => max_pfn_mapped => totalram_pages etc.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
