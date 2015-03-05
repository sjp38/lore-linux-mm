Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id D4F446B006E
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 11:52:39 -0500 (EST)
Received: by lbiz11 with SMTP id z11so26698822lbi.3
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 08:52:39 -0800 (PST)
Received: from mail.anarazel.de (mail.anarazel.de. [217.115.131.40])
        by mx.google.com with ESMTP id w3si25691662wia.48.2015.03.05.08.52.37
        for <linux-mm@kvack.org>;
        Thu, 05 Mar 2015 08:52:38 -0800 (PST)
Date: Thu, 5 Mar 2015 17:52:30 +0100
From: Andres Freund <andres@anarazel.de>
Subject: Re: [RFC 0/6] the big khugepaged redesign
Message-ID: <20150305165230.GQ30405@awork2.anarazel.de>
References: <1424696322-21952-1-git-send-email-vbabka@suse.cz>
 <1424731603.6539.51.camel@stgolabs.net>
 <20150223145619.64f3a225b914034a17d4f520@linux-foundation.org>
 <54EC533E.8040805@suse.cz>
 <54F88498.2000902@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54F88498.2000902@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Alex Thorlton <athorlton@sgi.com>, David Rientjes <rientjes@google.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Robert Haas <robertmhaas@gmail.com>, Josh Berkus <josh@agliodbs.com>

Hi,

On 2015-03-05 17:30:16 +0100, Vlastimil Babka wrote:
> That however means the workload is based on hugetlbfs and shouldn't trigger THP
> page fault activity, which is the aim of this patchset. Some more googling made
> me recall that last LSF/MM, postgresql people mentioned THP issues and pointed
> at compaction. See http://lwn.net/Articles/591723/ That's exactly where this
> patchset should help, but I obviously won't be able to measure this before LSF/MM...
> 
> I'm CCing the psql guys from last year LSF/MM - do you have any insight about
> psql performance with THPs enabled/disabled on recent kernels, where e.g.
> compaction is no longer synchronous for THP page faults?

What exactly counts as "recent" in this context? Most of the bigger
installations where we found THP to be absolutely prohibitive (slowdowns
on the order of a magnitude, huge latency spikes) unfortunately run
quite old kernels...  I guess 3.11 does *not* count :/? That'd be a
bigger machine where I could relatively quickly reenable THP to check
whether it's still bad. I might be able to trigger it to be rebooted
onto a newer kernel, will ask.

Greetings,

Andres Freund

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
