Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 069B46B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 12:49:04 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id p41so16010890lfi.0
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 09:49:03 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p125si21155517wmp.76.2016.07.19.09.49.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Jul 2016 09:49:02 -0700 (PDT)
Date: Tue, 19 Jul 2016 17:48:57 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/2] mm: add per-zone lru list stat
Message-ID: <20160719164857.GT11400@suse.de>
References: <1468943433-24805-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1468943433-24805-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jul 20, 2016 at 12:50:32AM +0900, Minchan Kim wrote:
> While I did stress test with hackbench, I got OOM message frequently
> which didn't ever happen in zone-lru.
> 

This one also showed pgdat going unreclaimable early. Have you tried any
of the three oom-related patches I sent to Joonsoo to see what impact,
if any, it had?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
