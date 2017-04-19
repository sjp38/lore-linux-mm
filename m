Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 08A626B03B3
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 09:54:28 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id r16so14875201ioi.7
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 06:54:28 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id v14si3091974iov.228.2017.04.19.06.54.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Apr 2017 06:54:27 -0700 (PDT)
Date: Wed, 19 Apr 2017 15:54:23 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC 2/4] Deactivate mmap_sem assert
Message-ID: <20170419135423.r5zykftem6hrusny@hirez.programming.kicks-ass.net>
References: <cover.1492595897.git.ldufour@linux.vnet.ibm.com>
 <582009a3f9459de3d8def1e76db46e815ea6153c.1492595897.git.ldufour@linux.vnet.ibm.com>
 <20170419123051.GA5730@worktop>
 <e6397c6c-6718-a0f3-0d72-7ad85760fdea@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e6397c6c-6718-a0f3-0d72-7ad85760fdea@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Davidlohr Bueso <dave@stgolabs.net>, akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, "Kirill A . Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, haren@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, Paul.McKenney@us.ibm.com, linux-kernel@vger.kernel.org

On Wed, Apr 19, 2017 at 03:45:50PM +0200, Laurent Dufour wrote:
> On 19/04/2017 14:30, Peter Zijlstra wrote:
> > On Wed, Apr 19, 2017 at 02:18:25PM +0200, Laurent Dufour wrote:
> >> When mmap_sem will be moved to a range lock, some assertion done in
> >> the code are no more valid, like the one ensuring mmap_sem is held.
> >>
> > 
> > Why are they no longer valid?
> 
> I didn't explain that very well..
> 
> When using a range lock we can't check that the lock is simply held, but
> if the range we are interesting on is locked or not.

I don't think it matters.. That is, in general you cannot assume
anything about the ranges, therefore, for deadlock analysis you have to
assume each range is the full range.

Once you're there, and assume that each range is the full range, this
test is once again trivial.

The fact that not all ranges are the full range, is merely a performance
consideration, but should not be a correctness issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
