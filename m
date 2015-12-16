Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 60B936B0255
	for <linux-mm@kvack.org>; Wed, 16 Dec 2015 00:43:06 -0500 (EST)
Received: by mail-ig0-f177.google.com with SMTP id to18so33764583igc.0
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 21:43:06 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTPS id b15si10099393ioj.143.2015.12.15.21.43.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 15 Dec 2015 21:43:05 -0800 (PST)
Date: Wed, 16 Dec 2015 14:44:45 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/2] mm/compaction: fix invalid free_pfn and
 compact_cached_free_pfn
Message-ID: <20151216054445.GB13808@js1304-P5Q-DELUXE>
References: <1450069341-28875-1-git-send-email-iamjoonsoo.kim@lge.com>
 <566E94C6.5080000@suse.cz>
 <CAAmzW4MEAYJKkQs9ksq+2aOA02xqekmruqwEv5e4szK7i7BjPw@mail.gmail.com>
 <566FCFEB.1020305@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <566FCFEB.1020305@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Aaron Lu <aaron.lu@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Tue, Dec 15, 2015 at 09:31:39AM +0100, Vlastimil Babka wrote:
> On 12/14/2015 04:26 PM, Joonsoo Kim wrote:
> >2015-12-14 19:07 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
> >>On 12/14/2015 06:02 AM, Joonsoo Kim wrote:
> >>>
> >>
> >>Acked-by: Vlastimil Babka <vbabka@suse.cz>
> >>
> >>Note that until now in compaction we've used basically an open-coded
> >>round_down(), and ALIGN() for rounding up. You introduce a first use of
> >>round_down(), and it would be nice to standardize on round_down() and
> >>round_up() everywhere. I think it's more obvious than open-coding and
> >>ALIGN() (which doesn't tell the reader if it's aligning up or down).
> >>Hopefully they really do the same thing and there are no caveats...
> >
> >Okay. Will send another patch for this clean-up on next spin.
> 
> Great, I didn't mean that the cleanup is needed right now, but
> whether we agree on an idiom to use whenever doing any changes from
> now on.

Okay.

> Maybe it would be best to add some defines in the top of
> compaction.c that would also hide away the repeated
> pageblock_nr_pages everywhere? Something like:
> 
> #define pageblock_start(pfn) round_down(pfn, pageblock_nr_pages)
> #define pageblock_end(pfn) round_up((pfn)+1, pageblock_nr_pages)

Quick grep shows that there are much more places this new define or
some variant can be used. It would be good clean-up. I will try it
separately.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
