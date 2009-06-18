Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id CF6B86B005C
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 20:55:56 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5I0vf5c028119
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 18 Jun 2009 09:57:41 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2FD7C45DE61
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 09:57:41 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 04DC045DE5D
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 09:57:41 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D72FD1DB8046
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 09:57:40 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8247A1DB803F
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 09:57:37 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH for -mm] getrusage: fill ru_maxrss value
In-Reply-To: <20090617132118.ef839ad7.akpm@linux-foundation.org>
References: <Pine.LNX.4.64.0904060811300.22841@blonde.anvils> <20090617132118.ef839ad7.akpm@linux-foundation.org>
Message-Id: <20090618095705.99D2.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 18 Jun 2009 09:57:36 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Hugh Dickins <hugh@veritas.com>, jpirko@redhat.com, linux-kernel@vger.kernel.org, oleg@redhat.com, linux-mm@kvack.org, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

> On Mon, 6 Apr 2009 08:22:07 +0100 (BST)
> Hugh Dickins <hugh@veritas.com> wrote:
> 
> > On Mon, 6 Apr 2009, KOSAKI Motohiro wrote:
> > > 
> > > > I'm worrying particularly about the fork/exec issue you highlight.
> > > > You're exemplary in providing your test programs, but there's a big
> > > > omission: you don't mention that the first test, "./getrusage -lc",
> > > > gives a very different result on Linux than you say it does on BSD -
> > > > you say the BSD fork line is "fork: self 0 children 0", whereas
> > > > I find my Linux fork line is "fork: self 102636 children 0".
> > > 
> > > FreeBSD update rusage at tick updating point. (I think all bsd do that)
> > > Then, bsd displaing 0 is bsd's problem :)
> > 
> > Ah, thank you.
> > 
> > > 
> > > Do I must change test program?
> > 
> > Apparently somebody needs to, please; though it appears to be already
> > well supplied with usleep(1)s - maybe they needed to be usleep(2)s?
> > 
> > And then change results shown in the changelog, and check conclusions
> > drawn from them (if BSD is behaving as we do, it should still show
> > maxrss not inherited over fork, but less obviously - the number goes
> > down slightly, because the history is lost, but nowhere near to zero).
> > 
> 
> afaik none of this happened, so I have the patch on hold.

Grr, my fault.
I recognize it. sorry.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
