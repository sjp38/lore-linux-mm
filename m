Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 5182C6B007D
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 10:18:56 -0500 (EST)
Received: by gv-out-0910.google.com with SMTP id n29so7241gve.19
        for <linux-mm@kvack.org>; Thu, 21 Jan 2010 07:18:54 -0800 (PST)
Subject: Re: [PATCH] oom-kill: add lowmem usage aware oom kill handling
From: Minchan Kim <minchan.kim@gmail.com>
In-Reply-To: <20100121145905.84a362bb.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100121145905.84a362bb.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 22 Jan 2010 00:18:44 +0900
Message-ID: <1264087124.1818.15.camel@barrios-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, rientjes@google.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi, Kame. 

On Thu, 2010-01-21 at 14:59 +0900, KAMEZAWA Hiroyuki wrote:
> A patch for avoiding oom-serial-killer at lowmem shortage.
> Patch is onto mmotm-2010/01/15 (depends on mm-count-lowmem-rss.patch)
> Tested on x86-64/SMP + debug module(to allocated lowmem), works well.
> 
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> One cause of OOM-Killer is memory shortage in lower zones.
> (If memory is enough, lowmem_reserve_ratio works well. but..)
> 
> In lowmem-shortage oom-kill, oom-killer choses a vicitim process
> on their vm size. But this kills a process which has lowmem memory
> only if it's lucky. At last, there will be an oom-serial-killer.
> 
> Now, we have per-mm lowmem usage counter. We can make use of it
> to select a good? victim.
> 
> This patch does
>   - add CONSTRAINT_LOWMEM to oom's constraint type.
>   - pass constraint to __badness()
>   - change calculation based on constraint. If CONSTRAINT_LOWMEM,
>     use low_rss instead of vmsize.

As far as low memory, it would be better to consider lowmem counter.
But as you know, {vmsize VS rss} is debatable topic.
Maybe someone doesn't like this idea. 

So don't we need any test result at least?
If we don't have this patch, it happens several innocent process
killing. but we can't prevent it by this patch. 

Sorry for bothering you.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
