Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 253986B0264
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 11:01:44 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r190so17981805wmr.0
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 08:01:44 -0700 (PDT)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id d16si1143390wjx.74.2016.07.15.08.01.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Jul 2016 08:01:42 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id 4FB379931A
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 15:01:42 +0000 (UTC)
Date: Fri, 15 Jul 2016 16:01:40 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 5/5] mm, vmscan: Update all zone LRU sizes before
 updating memcg
Message-ID: <20160715150140.GP9806@techsingularity.net>
References: <1468588165-12461-1-git-send-email-mgorman@techsingularity.net>
 <1468588165-12461-6-git-send-email-mgorman@techsingularity.net>
 <20160715144534.GA8644@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160715144534.GA8644@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 15, 2016 at 11:45:34PM +0900, Minchan Kim wrote:
> > +static __always_inline void update_lru_sizes(struct lruvec *lruvec,
> > +			enum lru_list lru, unsigned long *nr_zone_taken,
> > +			unsigned long nr_taken)
> > +{
> > +#ifdef CONFIG_HIGHMEM
> 
> If you think it's really worth to optimize it for non-highmem system,
> we don't need to account nr_zone_taken in *isolate_lru_pages*
> from the beginning for non-highmem system, either.
> 

It becomes a mess of ifdefs and given the marginal overhead, I left it
for now.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
