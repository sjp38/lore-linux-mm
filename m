Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 5BB856B0044
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 17:14:37 -0500 (EST)
From: Frans Pop <elendil@planet.nl>
Subject: Re: Page alloc problems with 2.6.32-rc kernels
Date: Wed, 4 Nov 2009 23:14:32 +0100
References: <20091102122010.GA5552@gibson.comsick.at> <200911040114.08879.elendil@planet.nl> <20091104071750.GA19287@gibson.comsick.at>
In-Reply-To: <20091104071750.GA19287@gibson.comsick.at>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Message-Id: <200911042314.35006.elendil@planet.nl>
Sender: owner-linux-mm@kvack.org
To: Michael Guntsche <mike@it-loops.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wednesday 04 November 2009, Michael Guntsche wrote:
> On 04 Nov 09 01:14, Frans Pop wrote:
> > Thanks Michael. That means we now have two cases where reverting the
> > congestion_wait() changes from .31-rc3 (8aa7e847d8 + 373c0a7ed3) makes
> > a clear and significant difference.
> >
> > I wonder if more effort could/should be made on this aspect.
>
> As a cross check I reverted the revert here and tried to reproduce the
> problem again. It is a lot harder to trigger for me now (I was not able
> to reproduce it yet). I did update my local git tree though,

OK. Can you tell us a bit more about your setup:
=2D how much RAM does the system have?
=2D what's so special about mutt in your case that it triggers these errors?
  - do you maybe have a huge mailbox, so mutt uses a lot of memory?
  - does starting/use mutt cause swapping when you see the errors?
=2D do you use disk encryption at all?
  - if you do, what is encrypted: the file system, swap, both?

=46rom your first mail it does look as if you had little free memory and th=
at=20
swap was in use.

> can you reproduce this problem on your side with current git?

Yes I can, but my test case is somewhat special as it forces a huge amount=
=20
of swapping. It does look as if your problem may also be related to=20
swapping activity.

Cheers,
=46JP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
