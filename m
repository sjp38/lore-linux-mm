Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 994F48E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 03:38:27 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c53so11894817edc.9
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 00:38:27 -0800 (PST)
Received: from outbound-smtp16.blacknight.com (outbound-smtp16.blacknight.com. [46.22.139.233])
        by mx.google.com with ESMTPS id 89si2191361edr.235.2018.12.18.00.38.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 00:38:26 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp16.blacknight.com (Postfix) with ESMTPS id C816C1C18EB
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 08:38:25 +0000 (GMT)
Date: Tue, 18 Dec 2018 08:38:24 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 05/14] mm, compaction: Skip pageblocks with reserved pages
Message-ID: <20181218083823.GI29005@techsingularity.net>
References: <20181214230310.572-1-mgorman@techsingularity.net>
 <20181214230310.572-6-mgorman@techsingularity.net>
 <b1d38179-4ccf-f34a-dffa-26c7957b8aed@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <b1d38179-4ccf-f34a-dffa-26c7957b8aed@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Linux-MM <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On Tue, Dec 18, 2018 at 09:08:02AM +0100, Vlastimil Babka wrote:
> On 12/15/18 12:03 AM, Mel Gorman wrote:
> > Reserved pages are set at boot time, tend to be clustered and almost
> > never become unreserved. When isolating pages for migrating, skip
> > the entire pageblock is one PageReserved page is encountered on the
> > grounds that it is highly probable the entire pageblock is reserved.
> 
> Agreed, but maybe since it's highly probable and not certain, this
> skipping should not be done on the highest compaction priority?
> 

I don't think that's necessary at this time. For the most part, you are
talking about one partial pageblock at best given how the early memory
allocator works so it would only ever be useful for a high-order kernel
allocation. Second, one of compactions primary problems is inefficient
scanning where viable pageblocks are easily skipped over or only partially
scanned which is something I'm still looking at. Lastly, maximum priority
compaction is rarely hit in practice as far as I can tell.

-- 
Mel Gorman
SUSE Labs
