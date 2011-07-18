Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 363FA6B0082
	for <linux-mm@kvack.org>; Mon, 18 Jul 2011 19:18:19 -0400 (EDT)
Date: Mon, 18 Jul 2011 16:18:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: NULL poniter dereference in isolate_lru_pages 2.6.39.1
Message-Id: <20110718161819.506fe97c.akpm@linux-foundation.org>
In-Reply-To: <CAEwNFnDwjWDF7Z4AUZg9rAHN6=n9nZ5tZe5U8USn7TpVCNsM6A@mail.gmail.com>
References: <CAGtzr3fm2=UJFRo2xSYhst0P4jCMT-EPjyPi3=icCrMtW0ij8w@mail.gmail.com>
	<CAEwNFnB8VXkTiMzJewtd7rSZ8keqkboNz-BBjw_UudquvsrK1A@mail.gmail.com>
	<alpine.DEB.2.00.1107081021040.29346@ubuntu>
	<CAEwNFnCsjRkauM5XvOqh1hLNOT3Hwu2m9pPqO+mCHq7rKLu0Gg@mail.gmail.com>
	<alpine.DEB.2.00.1107111550430.29346@ubuntu>
	<CAEwNFnCfsGn1qZbgXNNETFtZAzOSvxpJDcftNcuuSBDXUnxtmA@mail.gmail.com>
	<alpine.DEB.2.00.1107142044110.29346@ubuntu>
	<CAEwNFnDwjWDF7Z4AUZg9rAHN6=n9nZ5tZe5U8USn7TpVCNsM6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Chris Pearson <pearson.christopher.j@gmail.com>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, stable <stable@kernel.org>

On Tue, 19 Jul 2011 07:48:11 +0900 Minchan Kim <minchan.kim@gmail.com> wrote:

> Thanks for the test, Chris.
> Andrew.
> We should push this into -stable.

That's

commit d179e84ba5da1d0024087d1759a2938817a00f3f
Author:     Andrea Arcangeli <aarcange@redhat.com>
AuthorDate: Wed Jun 15 15:08:51 2011 -0700
Commit:     Linus Torvalds <torvalds@linux-foundation.org>
CommitDate: Wed Jun 15 20:04:02 2011 -0700

    mm: vmscan: do not use page_count without a page pin


> 
> On Fri, Jul 15, 2011 at 10:48 AM, Chris Pearson
> <pearson.christopher.j@gmail.com> wrote:
> > That definately fixed it. __MTBF was about 20 days on those systems, since that patch we've had 200 server days with no problems.
> >
> > Thanks!
> >
> > On Tue, 12 Jul 2011, Minchan Kim wrote:
> >
> >>Date: Tue, 12 Jul 2011 09:16:09 +0900
> >>From: Minchan Kim <minchan.kim@gmail.com>
> >>To: Chris Pearson <pearson.christopher.j@gmail.com>
> >>Cc: linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>,
> >> __ __Andrew Morton <akpm@linux-foundation.org>, stable <stable@kernel.org>
> >>Subject: Re: NULL poniter dereference in isolate_lru_pages 2.6.39.1
> >>
> >>On Tue, Jul 12, 2011 at 5:52 AM, Chris Pearson
> >><pearson.christopher.j@gmail.com> wrote:
> >>> We applied the patch to many servers. __No problems so far.
> >>>
> >>> The .config is attached.
> >>
> >>Thanks. I verified. The point where isolate_lru_pages + 0x225 is
> >>page_count exactly. So Andrea patch solves this problem apparently.
> >>Couldn't we throw this patch to stable tree?
> >>
> >>https://patchwork.kernel.org/patch/857442/
> >>
> >>>
> >>> What's the config option to get that debugging info in the future?
> >>
> >>CONFIG_DEBUG_INFO helps you. :)
> >>
> >>--
> >>Kind regards,
> >>Minchan Kim
> >>
> >
> 
> 
> 
> -- 
> Kind regards,
> Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
