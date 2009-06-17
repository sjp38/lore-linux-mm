Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 8BAB76B004F
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 16:21:08 -0400 (EDT)
Date: Wed, 17 Jun 2009 13:21:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH for -mm] getrusage: fill ru_maxrss value
Message-Id: <20090617132118.ef839ad7.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0904060811300.22841@blonde.anvils>
References: <20090405084902.GA4411@psychotron.englab.brq.redhat.com>
	<Pine.LNX.4.64.0904051736210.23536@blonde.anvils>
	<20090406091825.44F0.A69D9226@jp.fujitsu.com>
	<Pine.LNX.4.64.0904060811300.22841@blonde.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: kosaki.motohiro@jp.fujitsu.com, jpirko@redhat.com, linux-kernel@vger.kernel.org, oleg@redhat.com, linux-mm@kvack.org, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

On Mon, 6 Apr 2009 08:22:07 +0100 (BST)
Hugh Dickins <hugh@veritas.com> wrote:

> On Mon, 6 Apr 2009, KOSAKI Motohiro wrote:
> > 
> > > I'm worrying particularly about the fork/exec issue you highlight.
> > > You're exemplary in providing your test programs, but there's a big
> > > omission: you don't mention that the first test, "./getrusage -lc",
> > > gives a very different result on Linux than you say it does on BSD -
> > > you say the BSD fork line is "fork: self 0 children 0", whereas
> > > I find my Linux fork line is "fork: self 102636 children 0".
> > 
> > FreeBSD update rusage at tick updating point. (I think all bsd do that)
> > Then, bsd displaing 0 is bsd's problem :)
> 
> Ah, thank you.
> 
> > 
> > Do I must change test program?
> 
> Apparently somebody needs to, please; though it appears to be already
> well supplied with usleep(1)s - maybe they needed to be usleep(2)s?
> 
> And then change results shown in the changelog, and check conclusions
> drawn from them (if BSD is behaving as we do, it should still show
> maxrss not inherited over fork, but less obviously - the number goes
> down slightly, because the history is lost, but nowhere near to zero).
> 

afaik none of this happened, so I have the patch on hold.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
