Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B0EBD6B01AD
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 05:19:14 -0400 (EDT)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id o549J8G8018617
	for <linux-mm@kvack.org>; Fri, 4 Jun 2010 02:19:09 -0700
Received: from pvh11 (pvh11.prod.google.com [10.241.210.203])
	by kpbe19.cbf.corp.google.com with ESMTP id o549J7Hb022126
	for <linux-mm@kvack.org>; Fri, 4 Jun 2010 02:19:07 -0700
Received: by pvh11 with SMTP id 11so627433pvh.13
        for <linux-mm@kvack.org>; Fri, 04 Jun 2010 02:19:07 -0700 (PDT)
Date: Fri, 4 Jun 2010 02:19:01 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 08/18] oom: badness heuristic rewrite
In-Reply-To: <20100604085347.80c7b43f.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006040216370.26022@chino.kir.corp.google.com>
References: <20100601163627.245D.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006011140110.32024@chino.kir.corp.google.com> <20100602225252.F536.A69D9226@jp.fujitsu.com> <20100603161030.074d9b98.akpm@linux-foundation.org>
 <20100604085347.80c7b43f.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 4 Jun 2010, KAMEZAWA Hiroyuki wrote:

> > No, we'll sometime completely replace implementations.  There's no hard
> > rule apart from "whatever makes sense".  If wholesale replacement makes
> > sense as a patch-presentation method then we'll do that.
> > 
> I agree. 
> 
> IMHO.
> 
> But this series includes both of bug fixes and new features at random.
> Then, a small bugfixes, which doens't require refactoring, seems to do that.
> That's irritating guys (at least me) because it seems that he tries to sneak
> his own new logic into bugfix and moreover, it makes backport to distro difficult.

I'll reply to your proposed patch order in your other email, but please 
don't think that I'm trying to sneak anything in with this series :)  It's 
been posted here for months and everything has been fully open to review 
and comment.  Most of the patches that have been added on after the 
heuristic rewrite were things that came up later in testing and 
inspection, so I understand how the series has a somewhat awkward flow.  
I'll fix that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
