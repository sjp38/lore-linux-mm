Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 433A16B004A
	for <linux-mm@kvack.org>; Mon,  6 Jun 2011 10:26:34 -0400 (EDT)
Received: by pzk4 with SMTP id 4so2352871pzk.14
        for <linux-mm@kvack.org>; Mon, 06 Jun 2011 07:26:32 -0700 (PDT)
Date: Mon, 6 Jun 2011 23:26:23 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] mm: compaction: Abort compaction if too many pages are
 isolated and caller is asynchronous
Message-ID: <20110606142623.GF1686@barrios-laptop>
References: <20110531141402.GK19505@random.random>
 <20110531143734.GB13418@barrios-laptop>
 <20110531143830.GC13418@barrios-laptop>
 <20110602182302.GA2802@random.random>
 <20110602202156.GA23486@barrios-laptop>
 <20110602214041.GF2802@random.random>
 <BANLkTim1WjdHWOQp7bMg5pFFKp1SSFoLKw@mail.gmail.com>
 <20110602223201.GH2802@random.random>
 <BANLkTikA+ugFNS95Zs_o6QqG2u4r2g93=Q@mail.gmail.com>
 <20110606101557.GA5247@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110606101557.GA5247@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, Ury Stankevich <urykhy@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jun 06, 2011 at 11:15:57AM +0100, Mel Gorman wrote:
> On Fri, Jun 03, 2011 at 08:01:44AM +0900, Minchan Kim wrote:
> > On Fri, Jun 3, 2011 at 7:32 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> > > On Fri, Jun 03, 2011 at 07:23:48AM +0900, Minchan Kim wrote:

<snip>

> > >> AFAIK, it's final destination to go as compaction will not break lru
> > >> ordering if my patch(inorder-putback) is merged.
> > >
> > > Agreed. I like your patchset, sorry for not having reviewed it in
> > > detail yet but there were other issues popping up in the last few
> > > days.
> > 
> > No problem. it's urgent than mine. :)
> > 
> 
> I'm going to take the opportunity to apologise for not reviewing that
> series yet. I've been kept too busy with other bugs to set side the
> few hours I need to review the series. I'm hoping to get to it this
> week if everything goes well.

I am refactoring the code about migration.
Maybe, I will resend it on tomorrow.
I hope you guys reviews that. :)

Thanks, Mel.

> 
> -- 
> Mel Gorman
> SUSE Labs

-- 
Kind regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
