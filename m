Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id CA2AD6B004D
	for <linux-mm@kvack.org>; Wed, 27 May 2009 02:05:33 -0400 (EDT)
Received: by an-out-0708.google.com with SMTP id d14so2131987and.26
        for <linux-mm@kvack.org>; Tue, 26 May 2009 23:05:37 -0700 (PDT)
Date: Wed, 27 May 2009 15:05:08 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 2/3] add inactive ratio calculation function of each
 zone V2
Message-Id: <20090527150508.2ce7e57b.minchan.kim@barrios-desktop>
In-Reply-To: <20090526223002.f283bcd2.akpm@linux-foundation.org>
References: <20090521092321.ee57585e.minchan.kim@barrios-desktop>
	<20090526223002.f283bcd2.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Yasunori Goto <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 26 May 2009 22:30:02 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Thu, 21 May 2009 09:23:21 +0900 Minchan Kim <minchan.kim@gmail.com> wrote:
> 
> > Changelog since V1 
> >  o Change function name from calculate_zone_inactive_ratio to calculate_inactive_ratio
> >    - by Mel Gorman advise
> >  o Modify tab indent - by Mel Gorman advise
> 
> The first two patches still had various trivial whitespace bustages. 
> You don't need Mel to find these things when we have the very nice
> scripts/checkpatch.pl.  Please incorporate that script into your patch
> preparation tools

Oops. I thought I tried to do checkpatch.pl with my patches. 

> > This patch devide setup_per_zone_inactive_ratio with
> > per-zone inactive ratio calculaton.
> 
> The above sentence appears to be the changelog for this patch but it
> doesn't make a lot of sense.
> 
> afaict the changelog should be:
> 
> "factor the per-zone arithemetic inside
> setup_per_zone_inactive_ratio()'s loop into a a separate function,
> calculate_zone_inactive_ratio().  This function will be used in a later
> patch".
> 
> yes?

Exactly. 

I will repost this with your improved changelog.
Thanks. Andrew.



-- 
Kinds Regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
