Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3FA418D0039
	for <linux-mm@kvack.org>; Thu, 10 Feb 2011 09:06:10 -0500 (EST)
Date: Thu, 10 Feb 2011 14:05:43 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC PATCH] mm: handle simple case in free_pcppages_bulk()
Message-ID: <20110210140543.GJ17873@csn.ul.ie>
References: <1297338408-3590-1-git-send-email-namhyung@gmail.com> <AANLkTikEigbPsNMqqkmixYbCfD7Dz12YMcW2+GZbhUQq@mail.gmail.com> <1297343929.1449.3.camel@leonhard> <AANLkTimcLgsdEm6XKESc34Z=nsJkZqz8H1jR-ARZo_Gq@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <AANLkTimcLgsdEm6XKESc34Z=nsJkZqz8H1jR-ARZo_Gq@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Namhyung Kim <namhyung@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Feb 10, 2011 at 10:38:59PM +0900, Minchan Kim wrote:
> On Thu, Feb 10, 2011 at 10:18 PM, Namhyung Kim <namhyung@gmail.com> wrote:
> > 2011-02-10 (???), 22:10 +0900, Minchan Kim:
> >> Hello Namhyung,
> >>
> >
> > Hi Minchan,
> >
> >
> >> On Thu, Feb 10, 2011 at 8:46 PM, Namhyung Kim <namhyung@gmail.com> wrote:
> >> > Now I'm seeing that there are some cases to free all pages in a
> >> > pcp lists. In that case, just frees all pages in the lists instead
> >> > of being bothered with round-robin lists traversal.
> >>
> >> I though about that but I didn't send the patch.
> >> That's because many cases which calls free_pcppages_bulk(,
> >> pcp->count,..) are slow path so it adds comparison overhead on fast
> >> path while it loses the effectiveness in slow path.
> >>
> >
> > Hmm.. How about adding unlikely() then? Doesn't it help much here?
> 
> Yes. It would help but I am not sure how much it is.
> AFAIR, when Mel submit the patch, he tried to prove the effectiveness
> with some experiment and profiler.

Yep. Principally I *think* used netperf running UDP_STREAM for different
buffer sizes and compared oprofile output but I also ran a battery of
benchmarks to check for any other unexpected regression without profiling.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
