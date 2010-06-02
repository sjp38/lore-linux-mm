Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 27C086B01AD
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 17:35:14 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id o52LZ8n0032510
	for <linux-mm@kvack.org>; Wed, 2 Jun 2010 14:35:08 -0700
Received: from pzk2 (pzk2.prod.google.com [10.243.19.130])
	by hpaq1.eem.corp.google.com with ESMTP id o52LZ6Rd029579
	for <linux-mm@kvack.org>; Wed, 2 Jun 2010 14:35:07 -0700
Received: by pzk2 with SMTP id 2so2120370pzk.25
        for <linux-mm@kvack.org>; Wed, 02 Jun 2010 14:35:06 -0700 (PDT)
Date: Wed, 2 Jun 2010 14:35:01 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 13/18] oom: avoid race for oom killed tasks detaching
 mm prior to exit
In-Reply-To: <20100602104621.GA6152@laptop>
Message-ID: <alpine.DEB.2.00.1006021424330.32666@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com> <alpine.DEB.2.00.1006010016460.29202@chino.kir.corp.google.com> <20100601164026.2472.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006011158230.32024@chino.kir.corp.google.com>
 <20100601204342.GC20732@redhat.com> <20100602092819.58579806.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1006020230140.26724@chino.kir.corp.google.com> <20100602104621.GA6152@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2 Jun 2010, Nick Piggin wrote:

> Well there are a large number of patches with no objections, some of
> which are bug-fixes which may need to be backported to earlier kernels.
> It would be nice if the patchset would be rearranged so all these can
> be merged soon (I don't want the situation where a couple of patches
> hold up your entire patchset again).
> 

I've written fixes in this patchset and have merged Oleg's work into it, 
but I would stress that none of these are really bugfixes that fix an 
unstable condition: killing a task outside of current's cpuset even though 
it was needless isn't a bugfix, recalling the oom killer once a kthread 
has called unuse_mm() isn't a bugfix, etc.  So while they definitely are 
fixes that we'd like to see upstream at some point, hence they were merged 
here as well, their impact is not as severe as it may have been described 
outside of this thread.

I definitely don't want that situation where a couple of patches hold it 
up either, I'm waiting for something to work on.

> When you are reduced to a few patches changing major functionality, it
> could be eaiser to get those reviewed and merged on their own.
> 

What patches specifically do you think are 2.6.35-rc2 material?  
Otherwise, in my opinion, holding up this entire thing from being merged 
doesn't make a lot of sense based on order of patches.

> Well the merge window is closed and even if it wasn't the patches would
> be better to sit in -mm for a bit. So I don't think there is a big rush
> now, let's just get it right so everything is lined up to get into the
> next merge window.
> 

They already sat in -mm for six weeks, so I had stopped my work thinking 
they already had a path upstream then were abruptly removed with the only 
alternative left to me in being to fold incremental fixes into one another 
and repost.  There have been no changes to what was sitting in -mm for 
six weeks other than dropping the consolidation of sysctls, the unifying 
of the panic_on_oom semantics for pagefault ooms, and refactoring of the 
patchset.

I'm left in the position where people want certain patches merged first 
even though they won't say it's rc material, they want to me to base my 
patchset off what they speculatively believe Andrew will eventually merge 
in -mm in the first place from others, and they refuse to review both the 
implementation and design of the new heursitic.  It compounds my work 
every day with absolutely no forward progress being made and we've stalled 
out on all this work because nobody is actually getting involved in 
reviewing the patchset for Andrew.

I honestly don't understand why this entire patchset cannot be merged 
right now with a target of 2.6.36.  If you disagree, please show me the 
patches that you believe are rc material and the problems that they fix 
that are either regressions from current code or have a severe enough 
impact to warrant that type of consideration.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
