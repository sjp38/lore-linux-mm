Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id A4BD16B0069
	for <linux-mm@kvack.org>; Sun, 16 Feb 2014 00:26:31 -0500 (EST)
Received: by mail-pb0-f46.google.com with SMTP id um1so13940988pbc.19
        for <linux-mm@kvack.org>; Sat, 15 Feb 2014 21:26:31 -0800 (PST)
Received: from mail-pb0-x234.google.com (mail-pb0-x234.google.com [2607:f8b0:400e:c01::234])
        by mx.google.com with ESMTPS id oq9si10706712pac.238.2014.02.15.21.26.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 15 Feb 2014 21:26:30 -0800 (PST)
Received: by mail-pb0-f52.google.com with SMTP id jt11so13946687pbb.25
        for <linux-mm@kvack.org>; Sat, 15 Feb 2014 21:26:30 -0800 (PST)
Date: Sat, 15 Feb 2014 21:25:39 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [RFC PATCH] mm/vmscan: remove two un-needed mem_cgroup_page_lruvec()
 call
In-Reply-To: <CAL1ERfO4yYMRBO8XEM0oCwBb6NOqZRVGq648ncerM9XuyPPJkw@mail.gmail.com>
Message-ID: <alpine.LSU.2.11.1402152121180.13768@eggly.anvils>
References: <000001cf2ac7$9abf23b0$d03d6b10$%yang@samsung.com> <alpine.LSU.2.11.1402151953180.10073@eggly.anvils> <CAL1ERfO4yYMRBO8XEM0oCwBb6NOqZRVGq648ncerM9XuyPPJkw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang.kh@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Weijie Yang <weijie.yang@samsung.com>, riel@redhat.com, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Sun, 16 Feb 2014, Weijie Yang wrote:
> On Sun, Feb 16, 2014 at 12:00 PM, Hugh Dickins <hughd@google.com> wrote:
> > On Sun, 16 Feb 2014, Weijie Yang wrote:
> >
> >> In putback_inactive_pages() and move_active_pages_to_lru(),
> >> lruvec is already an input parameter and pages are all from this lruvec,
> >> therefore there is no need to call mem_cgroup_page_lruvec() in loop.
> >>
> >> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
> >
> > Looks plausible but I believe it's incorrect.  The lruvec passed in
> > is the one we took the pages from, but there's a small but real chance
> > that the page has become uncharged meanwhile, and should now be put back
> > on the root_mem_cgroup's lruvec instead of the original memcg's lruvec.
> 
> Hi Hugh,
> 
> Thanks for your review.
> Frankly speaking, I am not very sure about it, that is why I add a RFC tag here.
> So,  do we need update the reclaim_stat meanwhile as we change the lruvec?

No, it's not worth bothering about, it's only for stats and this is an
unlikely case; whereas wrong memcg can be a significant correctness issue.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
