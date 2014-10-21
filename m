Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 704D882BDA
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 06:59:40 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id et14so1166601pad.31
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 03:59:40 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id on3si10748909pbc.29.2014.10.21.03.59.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Oct 2014 03:59:39 -0700 (PDT)
Date: Tue, 21 Oct 2014 12:59:34 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [BUG] mm, thp: khugepaged can't allocate on requested node when
 confined to a cpuset
Message-ID: <20141021105934.GV23531@worktop.programming.kicks-ass.net>
References: <20141008191050.GK3778@sgi.com>
 <20141010092052.GU4750@worktop.programming.kicks-ass.net>
 <20141010185620.GA3745@sgi.com>
 <54385635.5020709@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54385635.5020709@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Alex Thorlton <athorlton@sgi.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Bob Liu <lliubbo@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

On Fri, Oct 10, 2014 at 11:57:09PM +0200, Vlastimil Babka wrote:
> Hm I haven't seen the code yet, but is perhaps the NUMA scanning working
> similarly enough that a single scanner could handle both the NUMA and THP
> bits to save time?

IIRC the THP thing doesn't need the fault thing, which makes it an
entirely different beast. Then again, we do walk the actual page-tables
through change_protection, but changing that means we have to duplicate
all that code, then again, maybe the current THP stuff already carries
something like that.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
