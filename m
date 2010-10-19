Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1ACDE6B00D8
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 01:33:26 -0400 (EDT)
Date: Tue, 19 Oct 2010 16:33:20 +1100
From: Nick Piggin <npiggin@kernel.dk>
Subject: Re: [patch 03/35] mm: implement per-zone shrinker
Message-ID: <20101019053320.GA7470@amd>
References: <20101019034216.319085068@kernel.dk>
 <20101019034655.756353382@kernel.dk>
 <20101019134345.A1E9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101019134345.A1E9.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: npiggin@kernel.dk, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Oct 19, 2010 at 01:49:12PM +0900, KOSAKI Motohiro wrote:
> Hi
> 
> > Index: linux-2.6/include/linux/mm.h
> > ===================================================================
> > --- linux-2.6.orig/include/linux/mm.h	2010-10-19 14:19:40.000000000 +1100
> > +++ linux-2.6/include/linux/mm.h	2010-10-19 14:36:48.000000000 +1100
> > @@ -997,6 +997,10 @@
> >  /*
> >   * A callback you can register to apply pressure to ageable caches.
> >   *
> > + * 'shrink_zone' is the new shrinker API. It is to be used in preference
> > + * to 'shrink'. One must point to a shrinker function, the other must
> > + * be NULL. See 'shrink_slab' for details about the shrink_zone API.
> 
...

> Now we decided to don't remove old (*shrink)() interface and zone unaware
> slab users continue to use it. so why do we need global argument?
> If only zone aware shrinker user (*shrink_zone)(), we can remove it.
> 
> Personally I think we should remove it because a removing makes a clear
> message that all shrinker need to implement zone awareness eventually.

I agree, I do want to remove the old API, but it's easier to merge if
I just start by adding the new API. It is split out from my previous
patch which does convert all users of the API. When this gets merged, I
will break those out and send them via respective maintainers, then
remove the old API when they're all converted upstream.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
