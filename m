Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3215F6B004D
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 21:48:24 -0400 (EDT)
Date: Fri, 10 Jul 2009 04:09:20 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC][PATCH 0/4] ZERO PAGE again v2
Message-ID: <20090710020920.GB15903@wotan.suse.de>
References: <20090707165101.8c14b5ac.kamezawa.hiroyu@jp.fujitsu.com> <20090707084750.GX2714@wotan.suse.de> <20090707180629.cd3ac4b6.kamezawa.hiroyu@jp.fujitsu.com> <20090707140033.GB2714@wotan.suse.de> <alpine.LFD.2.01.0907070952341.3210@localhost.localdomain> <20090708062125.GJ2714@wotan.suse.de> <alpine.LFD.2.01.0907080906410.3210@localhost.localdomain> <20090709074745.GT2714@wotan.suse.de> <alpine.LFD.2.01.0907091053100.3352@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.01.0907091053100.3352@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, avi@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 09, 2009 at 10:54:02AM -0700, Linus Torvalds wrote:
> 
> 
> On Thu, 9 Jul 2009, Nick Piggin wrote:
> >
> > Having a ZERO_PAGE I'm not against, so I don't know why you claim
> > I am. Al I'm saying is that now we don't have one, we should have
> > some good reasons to introduce it again. Unreasonable?
> 
> Umm. I had good reasons to introduce it in the _first_ place.
> 
> And now you have reports of people who depend on the behaviour, and point 
> to the new behaviour as a *regression*.
> 
> What the _hell_ more do you want?

Well there is obviously no way to test a representaive sample of
workoads, and we pretty much knew that some people are going to
prefer to have a ZERO_PAGE with their app.

So if you were going to re-add the zero page when a single regression
is reported after a year or two, then it was wrong of you to remove
the zero page to begin with.

So to answer your question, I guess I would like to know a bit
more about the regression and what the app is doing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
