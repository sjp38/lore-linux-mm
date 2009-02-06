Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8D8326B004F
	for <linux-mm@kvack.org>; Fri,  6 Feb 2009 18:37:55 -0500 (EST)
Date: Sat, 7 Feb 2009 00:37:14 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/3][RFC] swsusp: shrink file cache first
Message-ID: <20090206233714.GA3687@cmpxchg.org>
References: <20090206122129.79CC.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20090206044907.GA18467@cmpxchg.org> <20090206135302.628E.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20090206122417.GB1580@cmpxchg.org> <28c262360902060535g22facdd0tf082ca0abaec3f80@mail.gmail.com> <28c262360902060915u18b2fb54t5f2c1f44d03306e3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <28c262360902060915u18b2fb54t5f2c1f44d03306e3@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: MinChan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Feb 07, 2009 at 02:15:21AM +0900, MinChan Kim wrote:
> >>> Grr, you are right.
> >>> I agree, currently may_swap doesn't control swap out or not.
> >>> so I think we should change it correct name ;)
> >>
> >> Agreed.  What do you think about the following patch?
> >
> > As for me, I can't agree with you.
> > There are two kinds of file-mapped pages.
> >
> > 1. file-mapped and dirty page.
> > 2. file-mapped and no-dirty page
> >
> > Both pages are not swapped.
> > File-mapped and dirty page is synced with original file
> > File-mapped and no-dirty page is just discarded with viewpoint of reclaim.
> >
> > So, may_swap is just related to anon-pages
> > Thus, I think may_swap is reasonable.
> > How about you ?
> 
> Sorry for misunderstood your point.
> It would be better to remain more detaily for git log ?
> 
> 'may_swap' applies not only to anon pages but to mapped file pages as
> well. 'may_swap' term is sometime used for 'swap', sometime used for
> 'sync|discard'.
> In case of anon pages, 'may_swap' determines whether pages were swapout or not.
> but In case of mapped file pages, it determines whether pages are
> synced or discarded. so, 'may_swap' is rather awkward. Rename it to
> 'may_unmap' which is the actual meaning.
> 
> If you find wrong word and sentence, Please, fix it. :)

Cool, thanks.  I will resend an updated version soon with your
changelog text.  And on top of the two fixlets of this series which
Andrew already picked up.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
