Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id B771D6B0031
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 08:25:15 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id cc10so7515597wib.12
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 05:25:15 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.198])
        by mx.google.com with ESMTP id vh9si2601816wjc.146.2014.06.18.05.25.13
        for <linux-mm@kvack.org>;
        Wed, 18 Jun 2014 05:25:14 -0700 (PDT)
Date: Wed, 18 Jun 2014 15:24:42 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2 1/2] mm, thp: move invariant bug check out of loop in
 __split_huge_page_map
Message-ID: <20140618122442.GB5957@node.dhcp.inet.fi>
References: <1403044679-9993-1-git-send-email-Waiman.Long@hp.com>
 <1403044679-9993-2-git-send-email-Waiman.Long@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1403044679-9993-2-git-send-email-Waiman.Long@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <Waiman.Long@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Scott J Norton <scott.norton@hp.com>

On Tue, Jun 17, 2014 at 06:37:58PM -0400, Waiman Long wrote:
> In the __split_huge_page_map() function, the check for
> page_mapcount(page) is invariant within the for loop. Because of the
> fact that the macro is implemented using atomic_read(), the redundant
> check cannot be optimized away by the compiler leading to unnecessary
> read to the page structure.
> 
> This patch moves the invariant bug check out of the loop so that it
> will be done only once. On a 3.16-rc1 based kernel, the execution
> time of a microbenchmark that broke up 1000 transparent huge pages
> using munmap() had an execution time of 38,245us and 38,548us with
> and without the patch respectively. The performance gain is about 1%.

For this low difference it would be nice to average over few runs +
stddev. It can easily can be a noise.

> Signed-off-by: Waiman Long <Waiman.Long@hp.com>

But okay:

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
