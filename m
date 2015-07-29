Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id B3F716B0253
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 19:57:30 -0400 (EDT)
Received: by pdbnt7 with SMTP id nt7so13898447pdb.0
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 16:57:30 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id i10si17992983pdo.14.2015.07.29.16.57.28
        for <linux-mm@kvack.org>;
        Wed, 29 Jul 2015 16:57:29 -0700 (PDT)
Date: Thu, 30 Jul 2015 09:57:25 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC 1/4] mm, compaction: introduce kcompactd
Message-ID: <20150729235725.GN3902@dastard>
References: <alpine.DEB.2.10.1507091439100.17177@chino.kir.corp.google.com>
 <55AE0AFE.8070200@suse.cz>
 <alpine.DEB.2.10.1507211549380.3833@chino.kir.corp.google.com>
 <55AFB569.90702@suse.cz>
 <alpine.DEB.2.10.1507221509520.24115@chino.kir.corp.google.com>
 <55B0B175.9090306@suse.cz>
 <alpine.DEB.2.10.1507231358470.31024@chino.kir.corp.google.com>
 <55B1DF11.8070100@suse.cz>
 <alpine.DEB.2.10.1507281711250.12378@chino.kir.corp.google.com>
 <55B873DE.2060800@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55B873DE.2060800@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Wed, Jul 29, 2015 at 08:34:06AM +0200, Vlastimil Babka wrote:
> On 07/29/2015 02:33 AM, David Rientjes wrote:
> > On Fri, 24 Jul 2015, Vlastimil Babka wrote:
> > 
> >> > Two issues I want to bring up:
> >> > 
> >> >   (1) do non-thp configs benefit from periodic compaction?
> >> > 
> >> >       In my experience, no, but perhaps there are other use cases where
> >> >       this has been a pain.  The primary candidates, in my opinion,
> >> >       would be the networking stack and slub.  Joonsoo reports having to
> >> >       workaround issues with high-order slub allocations being too
> >> >       expensive.  I'm not sure that would be better served by periodic
> >> >       compaction, but it seems like a candidate for background compaction.
> >> 
> >> Yes hopefully a proactive background compaction would serve them enough.
> >> 
> >> >       This is why my rfc tied periodic compaction to khugepaged, and we
> >> >       have strong evidence that this helps thp and cpu utilization.  For
> >> >       periodic compaction to be possible outside of thp, we'd need a use
> >> >       case for it.

Allowing us to use higher order pages in the page cache to support
filesystem block sizes larger than page size without having to
care about memory fragmentation preventing page cache allocation?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
