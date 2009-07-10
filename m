Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id EB0B36B004D
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 23:30:08 -0400 (EDT)
Date: Fri, 10 Jul 2009 05:51:38 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [RFC][PATCH 0/4] ZERO PAGE again v2
Message-ID: <20090710035138.GA14666@wotan.suse.de>
References: <20090707084750.GX2714@wotan.suse.de> <20090707180629.cd3ac4b6.kamezawa.hiroyu@jp.fujitsu.com> <20090707140033.GB2714@wotan.suse.de> <alpine.LFD.2.01.0907070952341.3210@localhost.localdomain> <20090708062125.GJ2714@wotan.suse.de> <alpine.LFD.2.01.0907080906410.3210@localhost.localdomain> <20090709074745.GT2714@wotan.suse.de> <alpine.LFD.2.01.0907091053100.3352@localhost.localdomain> <20090710020920.GB15903@wotan.suse.de> <alpine.LFD.2.01.0907092034360.3352@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.01.0907092034360.3352@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, avi@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 09, 2009 at 08:38:41PM -0700, Linus Torvalds wrote:
> 
> 
> On Fri, 10 Jul 2009, Nick Piggin wrote:
> > 
> > So if you were going to re-add the zero page when a single regression
> > is reported after a year or two, then it was wrong of you to remove
> > the zero page to begin with.
> 
> Oh, I argued against it. And I told people we can always revert it.
> 
> But even better than reverting it is to just fix it cleanly in the new 
> world order, wouldn't you say?

If it is put back in without being refcounted, that should be
fine. That's what I first proposed for it (although you didn't
think my actua implementation was clean and preferred to remove
it completely).

I would like to see support for architectures which don't define
a pte_special bit too, however.


> > So to answer your question, I guess I would like to know a bit
> > more about the regression and what the app is doing.
> 
> Ok, go ahead and try to figure it out. But please don't cc me on it any 
> more. I'm not interested in your hang-ups with ZERO_PAGE.
> 
> Because I just don't care. I think ZERO_PAGE was great to begin with, I 
> put it to use muyself historically at Transmeta, and I didn't like your 
> crusade against it.
> 
> People (including me) have told you why it's useful. Whatever. If you 
> still want more information, go bother somebody else.

You're apparently not reading what I write when I do cc you, so
I don't think there would be much difference.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
