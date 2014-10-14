Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id A18A06B006C
	for <linux-mm@kvack.org>; Tue, 14 Oct 2014 13:39:16 -0400 (EDT)
Received: by mail-wg0-f49.google.com with SMTP id x12so11455052wgg.8
        for <linux-mm@kvack.org>; Tue, 14 Oct 2014 10:39:15 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.234])
        by mx.google.com with ESMTP id fq11si22006851wjc.169.2014.10.14.10.39.14
        for <linux-mm@kvack.org>;
        Tue, 14 Oct 2014 10:39:14 -0700 (PDT)
Date: Tue, 14 Oct 2014 20:38:37 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [BUG] mm, thp: khugepaged can't allocate on requested node when
 confined to a cpuset
Message-ID: <20141014173837.GA8919@node.dhcp.inet.fi>
References: <20141008191050.GK3778@sgi.com>
 <20141014114828.GA6524@node.dhcp.inet.fi>
 <20141014145435.GA7369@worktop.fdxtended.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141014145435.GA7369@worktop.fdxtended.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Alex Thorlton <athorlton@sgi.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Bob Liu <lliubbo@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

On Tue, Oct 14, 2014 at 04:54:35PM +0200, Peter Zijlstra wrote:
> > Is there a reason why we should respect cpuset limitation for kernel
> > threads?
> 
> Yes, because we want to allow isolating CPUs from 'random' activity.

Okay, it makes sense for cpus_allowed. But we're talking about
mems_allowed, right?
 
> 
> > Should we bypass cpuset for PF_KTHREAD completely?
> 
> No. That'll break stuff.

Like what?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
