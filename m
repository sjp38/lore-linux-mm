Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3E8D96008F1
	for <linux-mm@kvack.org>; Tue, 25 May 2010 05:46:14 -0400 (EDT)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id o4P9kA2a011871
	for <linux-mm@kvack.org>; Tue, 25 May 2010 02:46:11 -0700
Received: from pvc7 (pvc7.prod.google.com [10.241.209.135])
	by kpbe17.cbf.corp.google.com with ESMTP id o4P9jegw026071
	for <linux-mm@kvack.org>; Tue, 25 May 2010 02:46:09 -0700
Received: by pvc7 with SMTP id 7so2228146pvc.11
        for <linux-mm@kvack.org>; Tue, 25 May 2010 02:46:09 -0700 (PDT)
Date: Tue, 25 May 2010 02:46:06 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: oom killer rewrite
In-Reply-To: <20100524070714.GV2516@laptop>
Message-ID: <alpine.DEB.2.00.1005250242260.8045@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1005191511140.27294@chino.kir.corp.google.com> <20100524100840.1E95.A69D9226@jp.fujitsu.com> <20100524070714.GV2516@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 24 May 2010, Nick Piggin wrote:

> > > I've been notified that my entire oom killer rewrite has been dropped from 
> > > -mm based solely on your feedback.  The problem is that I have absolutely 
> > > no idea what issues you have with the changes that haven't already been 
> > > addressed (nobody else does, either, it seems).
> 
> I had exactly the same issues with the userland kernel API changes and
> the pagefault OOM regression it introduced, which I told you months ago.
> You ignored me, it seems.
> 

No, I didn't ignore you, your comments were specifically addressed with 
oom-reintroduce-and-deprecate-oom_kill_allocating_task.patch which only 
deprecated the API change and wasn't even scheduled for removal until of 
the end of 2011.  So there were no kernel API changes that went 
unaddressed, perhaps you just didn't see that patch (I cc'd it to you on 
April 27, though).

The pagefault oom behavior can now be changed back since you've converted 
all existing architectures to call into the oom killer and not simply kill 
current (thanks for that work!).  Previously, there was an inconsistency 
amongst architectures in panic_on_oom behavior that we can now unify into 
semantics that work across the board.

I've made that change in my latest patch series which I'll be posting 
shortly.

Thanks for the feedback!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
