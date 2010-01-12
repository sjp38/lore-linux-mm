Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0B3E26B0071
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 21:45:56 -0500 (EST)
Date: Tue, 12 Jan 2010 10:45:52 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH - resend] Memory-Hotplug: Fix the bug on interface
	/dev/mem for 64-bit kernel(v1)
Message-ID: <20100112024552.GA19425@localhost>
References: <DA586906BA1FFC4384FCFD6429ECE86031560BAC@shzsmsx502.ccr.corp.intel.com> <20100108124851.GB6153@localhost> <DA586906BA1FFC4384FCFD6429ECE86031560FC1@shzsmsx502.ccr.corp.intel.com> <20100111124303.GA21408@localhost> <20100112093031.0fc6877f.kamezawa.hiroyu@jp.fujitsu.com> <4B4BD281.4080009@linux.intel.com> <20100112103944.a9b1db76.kamezawa.hiroyu@jp.fujitsu.com> <20100112105012.4a210a1c.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100112105012.4a210a1c.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andi Kleen <ak@linux.intel.com>, "Zheng, Shaohui" <shaohui.zheng@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "y-goto@jp.fujitsu.com" <y-goto@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, "x86@kernel.org" <x86@kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 12, 2010 at 09:50:12AM +0800, KAMEZAWA Hiroyuki wrote:

> Just an information.
> 
> We already check kenerke/resource.c's resource information, here.
> 
> read_mem()
> 	-> range_is_allowed()
> 		-> devmem_is_allowd()
> 			-> iomem_is_exclusive()
> 
> extra calls of page_is_ram() to ask architecture's map seems redundunt.
> 
> But, I know PPC guys doesn't use ioresource.c, hehe.

Another exception is !CONFIG_STRICT_DEVMEM, which makes
range_is_allowed()==1. So we still need the page_is_ram() :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
