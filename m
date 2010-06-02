Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6CD066B01AC
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 05:50:03 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id o529ntcH004889
	for <linux-mm@kvack.org>; Wed, 2 Jun 2010 02:49:57 -0700
Received: from pzk31 (pzk31.prod.google.com [10.243.19.159])
	by wpaz21.hot.corp.google.com with ESMTP id o529nrDa027351
	for <linux-mm@kvack.org>; Wed, 2 Jun 2010 02:49:54 -0700
Received: by pzk31 with SMTP id 31so2919110pzk.16
        for <linux-mm@kvack.org>; Wed, 02 Jun 2010 02:49:53 -0700 (PDT)
Date: Wed, 2 Jun 2010 02:49:49 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 13/18] oom: avoid race for oom killed tasks detaching
 mm prior to exit
In-Reply-To: <20100602092819.58579806.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006020230140.26724@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com> <alpine.DEB.2.00.1006010016460.29202@chino.kir.corp.google.com> <20100601164026.2472.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006011158230.32024@chino.kir.corp.google.com>
 <20100601204342.GC20732@redhat.com> <20100602092819.58579806.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Oleg Nesterov <oleg@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2 Jun 2010, KAMEZAWA Hiroyuki wrote:

> > > No, it applies to mmotm-2010-05-21-16-05 as all of these patches do. I
> > > know you've pushed Oleg's patches
> > 
> > (plus other fixes)
> > 
> > > but they are also included here so no
> > > respin is necessary unless they are merged first (and I think that should
> > > only happen if Andrew considers them to be rc material).
> > 
> > Well, I disagree.
> > 
> > I think it is always better to push the simple bugfixes first, then
> > change/improve the logic.
> > 
> yes..yes...I hope David finish easy-to-be-merged ones and go to new stage.
> IOW, please reduce size of patches sent at once.
> 

How do you define "easy-to-be-merged"?  We've been through several 
iterations of this patchset where the end result is that it's been merged 
in -mm once, removed from -mm six weeks later, and nobody providing any 
feedback that I can work from.  Providing simple "nack" emails does 
nothing for the development of the patchset unless you actively get 
involved in the review process and subsequent discussion on how to move 
forward.

Listen, I want to hear everybody's ideas and suggestions on improvements.  
In fact, I think I've responded in a way that demonstrates that quite 
well: I've dropped the consolidation of sysctls, I've avoided deprecation 
of existing sysctls, I've unified the semantics of panic_on_oom, and I've 
split out patches where possible.  All of those were at the requests of 
people whom I've asked to review this patchset time and time again.

Kame, you've been very helpful in your feedback with regards to this 
patchset and I've valued your feedback from the first revision.  We had 
some differing views of how to handle task selection early on in other 
threads, but I sincerely enjoy hearing your feedback because it's 
interesting and challenging; you find things that I've missed and 
challenge me to defend decisions that were made.  I really, really like 
doing that type of development, I just wish we all could make some forward 
progress on this thing instead of staling out all the time.

I'm asking everyone to please review this work and comment on what you 
don't like or provide suggestions on how to improve it.  It's been posted 
in its various forms about eight times now over the course of a few 
months, I really hope there's no big surprises in it to anyone anymore.  
Sure, there are cleanups here that possibly could be considered rc 
material even though they admittedly aren't critical, but that isn't a 
reason to just stall out all of this work.  I'm sure Andrew can decide 
what he wants to merge into 2.6.35-rc2 after looking at the discussion and 
analyzing the impact; let us please focus on the actual implementation and 
design choices of the new oom killer presented here rather than get 
sidetracked.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
