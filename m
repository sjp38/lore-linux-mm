Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id BF3A76B03D7
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 10:07:01 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id f21so61028078pgi.4
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 07:07:01 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id u8si3535443plk.103.2017.03.08.07.07.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 07:07:00 -0800 (PST)
Date: Wed, 8 Mar 2017 07:06:59 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC PATCH 3/4] xfs: map KM_MAYFAIL to __GFP_RETRY_MAYFAIL
Message-ID: <20170308150659.GA24535@infradead.org>
References: <20170307154843.32516-1-mhocko@kernel.org>
 <20170307154843.32516-4-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170307154843.32516-4-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, "Darrick J. Wong" <darrick.wong@oracle.com>

On Tue, Mar 07, 2017 at 04:48:42PM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> KM_MAYFAIL didn't have any suitable GFP_FOO counterpart until recently
> so it relied on the default page allocator behavior for the given set
> of flags. This means that small allocations actually never failed.
> 
> Now that we have __GFP_RETRY_MAYFAIL flag which works independently on the
> allocation request size we can map KM_MAYFAIL to it. The allocator will
> try as hard as it can to fulfill the request but fails eventually if
> the progress cannot be made.

I don't think we really need this - KM_MAYFAIL is basically just
a flag to not require the retry loop around kmalloc for those places
in XFS that can deal with allocation failures.  But if the default
behavior is to not fail we'll happily take that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
