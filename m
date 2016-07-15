Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 127896B0263
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 06:46:09 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id o80so12373687wme.1
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 03:46:09 -0700 (PDT)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id xq13si95113wjb.276.2016.07.15.03.46.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jul 2016 03:46:07 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id 5BB9F1C1A41
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 11:46:07 +0100 (IST)
Date: Fri, 15 Jul 2016 11:46:05 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 18/34] mm: rename NR_ANON_PAGES to NR_ANON_MAPPED
Message-ID: <20160715104605.GO9806@techsingularity.net>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-19-git-send-email-mgorman@techsingularity.net>
 <20160712145801.GJ5881@cmpxchg.org>
 <20160713085516.GI9806@techsingularity.net>
 <20160713130415.GB9905@cmpxchg.org>
 <20160713133701.GK9806@techsingularity.net>
 <20160713141343.244c108e48086055f57b1d79@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160713141343.244c108e48086055f57b1d79@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 13, 2016 at 02:13:43PM -0700, Andrew Morton wrote:
> On Wed, 13 Jul 2016 14:37:01 +0100 Mel Gorman <mgorman@techsingularity.net> wrote:
> 
> > > I don't care strongly enough to cause a respin of half the series, and
> > > it's not your problem that I waited until the last revision went into
> > > mmots to review and comment. But if you agreed to a revert, would you
> > > consider tacking on a revert patch at the end of the series?
> > > 
> > 
> > In this case, I'm going to ask the other people on the cc for a
> > tie-breaker. If someone else prefers the old names then I'm happy for
> > your patch to be applied on top with my ack instead of respinning the
> > whole series.
> > 
> > Anyone for a tie breaker?
> 
> I am aggressively undecided.  I guess as it's a bit of a 51/49
> situation, the "stay with what people are familiar with" benefit tips the
> balance toward the legacy names?
> 

I still can't decide. It's currently still a draw in terms of naming. If
you're worried, use the old naming. It wouldn't be the first time I
thought a name was odd.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
