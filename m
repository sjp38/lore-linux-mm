Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E9B056B0011
	for <linux-mm@kvack.org>; Mon,  9 May 2011 19:03:00 -0400 (EDT)
Date: Tue, 10 May 2011 01:02:55 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 1/4] VM/RMAP: Add infrastructure for batching the rmap chain locking
Message-ID: <20110509230255.GA6008@one.firstfloor.org>
References: <1304623972-9159-1-git-send-email-andi@firstfloor.org> <1304623972-9159-2-git-send-email-andi@firstfloor.org> <20110509144324.8e79654a.akpm@linux-foundation.org> <4DC86947.30607@linux.intel.com> <20110509152841.ec957d23.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110509152841.ec957d23.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <ak@linux.intel.com>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, tim.c.chen@linux.intel.com, torvalds@linux-foundation.org, lwoodman@redhat.com, mel@csn.ul.ie

On Mon, May 09, 2011 at 03:28:41PM -0700, Andrew Morton wrote:
> On Mon, 09 May 2011 15:23:03 -0700
> Andi Kleen <ak@linux.intel.com> wrote:
> 
> > > After fixing that and doing an allnoconfig x86_64 build, the patchset
> > > takes rmap.o's .text from 6167 bytes to 6551.  This is likely to be a
> > > regression for uniprocessor machines.  What can we do about this?
> > >
> > 
> > Regression in what way?
> 
> It makes the code larger and probably slower, for no gain?

It should be actually faster because there are much less atomic ops.
Atomic ops are quite expensive -- especially on some older CPUs, even when
not contended.

> 
> > I guess I can move some of the functions out of 
> > line.
> 
> I don't know how much that will help.  Perhaps a wholesale refactoring
> and making it all SMP-only will be justified.  

Yes I don't think there were a lot of callers.

I can take out the lockbreak. I was a bit dubious on its utility
anyways.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
