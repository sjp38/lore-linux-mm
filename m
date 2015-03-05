Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id 444B66B0075
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 12:07:59 -0500 (EST)
Received: by wevl61 with SMTP id l61so17330332wev.0
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 09:07:58 -0800 (PST)
Received: from mail.anarazel.de (mail.anarazel.de. [217.115.131.40])
        by mx.google.com with ESMTP id ma1si13729097wjb.135.2015.03.05.09.07.57
        for <linux-mm@kvack.org>;
        Thu, 05 Mar 2015 09:07:57 -0800 (PST)
Date: Thu, 5 Mar 2015 18:07:52 +0100
From: Andres Freund <andres@anarazel.de>
Subject: Re: [RFC 0/6] the big khugepaged redesign
Message-ID: <20150305170752.GS30405@awork2.anarazel.de>
References: <1424696322-21952-1-git-send-email-vbabka@suse.cz>
 <1424731603.6539.51.camel@stgolabs.net>
 <20150223145619.64f3a225b914034a17d4f520@linux-foundation.org>
 <54EC533E.8040805@suse.cz>
 <54F88498.2000902@suse.cz>
 <20150305165230.GQ30405@awork2.anarazel.de>
 <54F88BD4.3090006@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54F88BD4.3090006@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Alex Thorlton <athorlton@sgi.com>, David Rientjes <rientjes@google.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Robert Haas <robertmhaas@gmail.com>, Josh Berkus <josh@agliodbs.com>

On 2015-03-05 18:01:08 +0100, Vlastimil Babka wrote:
> On 03/05/2015 05:52 PM, Andres Freund wrote:
> > What exactly counts as "recent" in this context? Most of the bigger
> > installations where we found THP to be absolutely prohibitive (slowdowns
> > on the order of a magnitude, huge latency spikes) unfortunately run
> > quite old kernels...  I guess 3.11 does *not* count :/? That'd be a
> 
> Yeah that's too old :/

Guessed so.

> I also noticed that you now support hugetlbfs. That could be also interesting
> data point, if the hugetlbfs usage helped because THP code wouldn't
> trigger.

Well, mmap(MAP_HUGETLB), but yea.

Will let you know once I know whether it's possible to get a newer kernel.

Greetings,

Andres Freund

-- 
 Andres Freund	                   http://www.2ndQuadrant.com/
 PostgreSQL Development, 24x7 Support, Training & Services

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
