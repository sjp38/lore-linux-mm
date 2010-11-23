Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 3C0216B0088
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 09:55:55 -0500 (EST)
Received: by qwj8 with SMTP id 8so57580qwj.14
        for <linux-mm@kvack.org>; Tue, 23 Nov 2010 06:55:53 -0800 (PST)
From: Ben Gamari <bgamari@gmail.com>
Subject: Re: [RFC 1/2] deactive invalidated pages
In-Reply-To: <20101123093859.GE19571@csn.ul.ie>
References: <bdd6628e81c06f6871983c971d91160fca3f8b5e.1290349672.git.minchan.kim@gmail.com> <20101122141449.9de58a2c.akpm@linux-foundation.org> <AANLkTimk4JL7hDvLWuHjiXGNYxz8GJ_TypWFC=74Xt1Q@mail.gmail.com> <20101122210132.be9962c7.akpm@linux-foundation.org> <20101123093859.GE19571@csn.ul.ie>
Date: Tue, 23 Nov 2010 09:55:49 -0500
Message-ID: <87k4k49jii.fsf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Tue, 23 Nov 2010 09:38:59 +0000, Mel Gorman <mel@csn.ul.ie> wrote:
> > If it's mapped pagecache then the user was being a bit silly (or didn't
> > know that some other process had mapped the file).  In which case we
> > need to decide what to do - leave the page alone, deactivate it, or
> > half-deactivate it as this patch does.
> > 
> 
> What are the odds of an fadvise() user having used mincore() in advance
> to determine if the page was in use by another process? I would guess
> "low" so this half-deactivate gives a chance for the page to be promoted
> again as well as a chance for the flusher threads to clean the page if
> it really is to be reclaimed.
> 
Do we really want to make the user jump through such hoops as using
mincore() just to get the kernel to handle use-once pages properly?
I hope the answer is no. I know that fadvise isn't supposed to be a
magic bullet, but it would be nice if more processes would use it to
indicate their access patterns and the only way that will happen is if
it is reasonably straightforward to use.

- Ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
