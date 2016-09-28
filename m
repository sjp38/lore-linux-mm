Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 819EA6B0271
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 03:41:04 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l138so31709991wmg.3
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 00:41:04 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id f13si7153391wjz.114.2016.09.28.00.41.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Sep 2016 00:41:00 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 009E21C21C4
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 08:40:59 +0100 (IST)
Date: Wed, 28 Sep 2016 08:40:58 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: page_waitqueue() considered harmful
Message-ID: <20160928074058.GB3903@techsingularity.net>
References: <CA+55aFwVSXZPONk2OEyxcP-aAQU7-aJsF3OFXVi8Z5vA11v_-Q@mail.gmail.com>
 <20160927083104.GC2838@techsingularity.net>
 <20160928005318.2f474a70@roar.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160928005318.2f474a70@roar.ozlabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>

On Wed, Sep 28, 2016 at 12:53:18AM +1000, Nicholas Piggin wrote:
> > The patch is heavily derived from work by Nick Piggin who noticed the years
> > before that. I think that was the last version I posted and the changelog
> > includes profile data. I don't have an exact reference why it was rejected
> > but a consistent piece of feedback was that it was very complex for the
> > level of impact it had.
> 
> Huh, I was just wondering about this again the other day. Powerpc has
> some interesting issues with atomic ops and barriers (not to mention
> random cache misses that hurt everybody).
> 
> It actually wasn't for big Altix machines (at least not when I wrote it),
> but it came from some effort to optimize page reclaim performance on an
> opteron with a lot (back then) of cores per node.
> 

The reason SUSE carried the patch for a while, albeit not right now, was
because of the large machines and them being the only people that could
provide concrete support. Over time, the benefit dropped.

It was always the case the benefit of the patch could be measured from
profiles but rarely visible in the context of the overall workload or
buried deep within the noise.

The final structure of the patch was partially driven by fixes for subtle
bugs discovered in the patch over a long period of time. Maybe the new
approaches will both avoid those bugs and be visible on "real"
workloads.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
