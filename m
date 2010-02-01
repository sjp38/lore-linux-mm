Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id AC7366B0085
	for <linux-mm@kvack.org>; Sun, 31 Jan 2010 23:42:41 -0500 (EST)
Date: Mon, 1 Feb 2010 12:41:24 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [Patch - Resend v4] Memory-Hotplug: Fix the bug on interface
	/dev/mem for 64-bit kernel
Message-ID: <20100201044124.GA29097@localhost>
References: <20100201041253.GA1028@shaohui>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100201041253.GA1028@shaohui>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, y-goto@jp.fujitsu.com, haveblue@us.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, ak@linux.intel.com, hpa@kernel.org, haicheng.li@intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

Shaohui,

Some style nitpicks..

>  #ifdef CONFIG_MEMORY_HOTPLUG
> +/**

Should use /* here. 

> + * After memory hotplug, the variable max_pfn, max_low_pfn and high_memory will
> + * be affected, it will be updated in this function.
> + */
> +static inline void __meminit update_end_of_memory_vars(u64 start,

The "inline" and "__meminit" are both redundant here.

> +		max_low_pfn = max_pfn = end_pfn;

One assignment per line is preferred.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
