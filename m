Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 279D76B0078
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 04:00:42 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0C90dHU016761
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 12 Jan 2010 18:00:39 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D2C9245DE51
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 18:00:38 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id ABD1B45DE57
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 18:00:38 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9859A1DB803E
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 18:00:38 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 49F11E78002
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 18:00:38 +0900 (JST)
Date: Tue, 12 Jan 2010 17:57:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [ RESEND PATCH v3] Memory-Hotplug: Fix the bug on interface
 /dev/mem for 64-bit kernel
Message-Id: <20100112175724.adfa04d6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <DA586906BA1FFC4384FCFD6429ECE860316C01D6@shzsmsx502.ccr.corp.intel.com>
References: <DA586906BA1FFC4384FCFD6429ECE860316C0133@shzsmsx502.ccr.corp.intel.com>
	<20100112170433.394be31b.kamezawa.hiroyu@jp.fujitsu.com>
	<DA586906BA1FFC4384FCFD6429ECE860316C01D6@shzsmsx502.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Zheng, Shaohui" <shaohui.zheng@intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "ak@linux.intel.com" <ak@linux.intel.com>, "y-goto@jp.fujitsu.com" <y-goto@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, "x86@kernel.org" <x86@kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 12 Jan 2010 16:57:40 +0800
"Zheng, Shaohui" <shaohui.zheng@intel.com> wrote:

> 
> 3 points...
> 1. I think this patch cannot be compiled in archs other than x86. Right ?
>    IOW, please add static inline dummy...
> [Zheng, Shaohui] Agree, I will add a static dummy function
> 
> 2. pgdat->[start,end], totalram_pages etc...are updated at memory hotplug.
>    Please place the hook nearby them.
> [Zheng, Shaohui] Agree.
> 
> 3. I recommend you yo use memory hotplug notifier.
>    If it's allowed, it will be cleaner.
>    It seems there are no strict ordering to update parameters this patch touches.
> 
> [Zheng, Shaohui] Kame, do you means put the hook into function slab_mem_going_online_callback, it seems a good idea. If we select this method, we will need not to update these variable in function add_memory explicitly.
> 
yes. I think callback is the best.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
