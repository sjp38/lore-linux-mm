Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5A9A96B0083
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 00:10:19 -0500 (EST)
Message-ID: <4B46BC6F.5060607@kernel.org>
Date: Thu, 07 Jan 2010 21:02:39 -0800
From: "H. Peter Anvin" <hpa@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH - resend] Memory-Hotplug: Fix the bug on interface /dev/mem
 for 64-bit kernel(v1)
References: <DA586906BA1FFC4384FCFD6429ECE86031560BAC@shzsmsx502.ccr.corp.intel.com>
In-Reply-To: <DA586906BA1FFC4384FCFD6429ECE86031560BAC@shzsmsx502.ccr.corp.intel.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Zheng, Shaohui" <shaohui.zheng@intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "ak@linux.intel.com" <ak@linux.intel.com>, "y-goto@jp.fujitsu.com" <y-goto@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, "x86@kernel.org" <x86@kernel.org>
List-ID: <linux-mm.kvack.org>

On 01/07/2010 07:32 PM, Zheng, Shaohui wrote:
> Resend the patch to the mailing-list, the original patch URL is 
> http://patchwork.kernel.org/patch/69075/, it is not accepted without comments,
> sent it again to review.
> 
> Memory-Hotplug: Fix the bug on interface /dev/mem for 64-bit kernel
> 
> The new added memory can not be access by interface /dev/mem, because we do not
>  update the variable high_memory. This patch add a new e820 entry in e820 table,
>  and update max_pfn, max_low_pfn and high_memory.
> 
> We add a function update_pfn in file arch/x86/mm/init.c to udpate these
>  varibles. Memory hotplug does not make sense on 32-bit kernel, so we did not
>  concern it in this function.
> 

Memory hotplug makes sense on 32-bit kernels, at least in virtual
environments.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
