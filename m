Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f180.google.com (mail-ie0-f180.google.com [209.85.223.180])
	by kanga.kvack.org (Postfix) with ESMTP id 708866B0036
	for <linux-mm@kvack.org>; Mon, 28 Jul 2014 18:24:26 -0400 (EDT)
Received: by mail-ie0-f180.google.com with SMTP id at20so7236589iec.25
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 15:24:26 -0700 (PDT)
Received: from mail-ie0-x235.google.com (mail-ie0-x235.google.com [2607:f8b0:4001:c03::235])
        by mx.google.com with ESMTPS id o6si19338895igi.0.2014.07.28.15.24.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 28 Jul 2014 15:24:25 -0700 (PDT)
Received: by mail-ie0-f181.google.com with SMTP id rp18so7469275iec.40
        for <linux-mm@kvack.org>; Mon, 28 Jul 2014 15:24:25 -0700 (PDT)
Date: Mon, 28 Jul 2014 15:24:22 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, thp: restructure thp avoidance of light synchronous
 migration
In-Reply-To: <53D60F31.4050504@suse.cz>
Message-ID: <alpine.DEB.2.02.1407281523090.8998@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1407241540190.22557@chino.kir.corp.google.com> <53D60F31.4050504@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 28 Jul 2014, Vlastimil Babka wrote:

> Looks like kind of a shotgun approach to me. A single __GFP_NO_KSWAPD bullet
> is no longer enough, so we use all the flags and hope for the best. It seems
> THP has so many flags it should be unique for now, but I wonder if there is a
> better way to say how much an allocation is willing to wait.
> 

We would have to introduce a new __GFP_FAULT bit to distinguish between 
allocations at pagefault that should not use synchronous memory compaction 
solely for this case, it's probably not worth it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
