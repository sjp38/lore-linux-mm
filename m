Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id D38636B025E
	for <linux-mm@kvack.org>; Wed, 20 Jul 2016 06:55:55 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id p41so30053132lfi.0
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 03:55:55 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q185si26252469wmg.57.2016.07.20.03.55.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Jul 2016 03:55:54 -0700 (PDT)
Date: Wed, 20 Jul 2016 11:55:49 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/2] mm: add per-zone lru list stat
Message-ID: <20160720105549.GU11400@suse.de>
References: <1468943433-24805-1-git-send-email-minchan@kernel.org>
 <20160719164857.GT11400@suse.de>
 <20160720001624.GA25472@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160720001624.GA25472@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jul 20, 2016 at 09:16:24AM +0900, Minchan Kim wrote:
> On Tue, Jul 19, 2016 at 05:48:57PM +0100, Mel Gorman wrote:
> > On Wed, Jul 20, 2016 at 12:50:32AM +0900, Minchan Kim wrote:
> > > While I did stress test with hackbench, I got OOM message frequently
> > > which didn't ever happen in zone-lru.
> > > 
> > 
> > This one also showed pgdat going unreclaimable early. Have you tried any
> > of the three oom-related patches I sent to Joonsoo to see what impact,
> > if any, it had?
> 
> Before the result, I want to say goal of this patch, again.
> Without per-zone lru stat, it's really hard to debug OOM problem in
> multiple zones system so regardless of solving the problem, we should add
> per-zone lru stat for debuggability of OOM which has been never perfect
> solution, ever.
> 

That's not in dispute, I simply wanted to know the impact.

> The result is not OOM but hackbench stalls forever.

Ok, that points to both the premature marking pgdats as unreclaimable
and the inactive rotation are both problems.

I have a series prepared that may or may not address the problem. I'm
trying to reproduce the OOM killer on a 32-bit KVM but so far so luck.
If I fail to reproduce it then I cannot tell if the series has an impact
and may have to post it and hope you and Joonsoo can test it.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
