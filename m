Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A1D748E0001
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 09:30:29 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id f31so5729716edf.17
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 06:30:29 -0800 (PST)
Received: from outbound-smtp26.blacknight.com (outbound-smtp26.blacknight.com. [81.17.249.194])
        by mx.google.com with ESMTPS id g40si5758160edc.423.2018.12.17.06.30.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 06:30:28 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp26.blacknight.com (Postfix) with ESMTPS id 1E95AB8B79
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 14:30:28 +0000 (GMT)
Date: Mon, 17 Dec 2018 14:30:26 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 04/14] mm, compaction: Rename map_pages to split_map_pages
Message-ID: <20181217143026.GG29005@techsingularity.net>
References: <20181214230310.572-1-mgorman@techsingularity.net>
 <20181214230310.572-5-mgorman@techsingularity.net>
 <b9a6574a-6b0c-11bc-06e5-c650b03e06f3@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <b9a6574a-6b0c-11bc-06e5-c650b03e06f3@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Linux-MM <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On Mon, Dec 17, 2018 at 03:06:59PM +0100, Vlastimil Babka wrote:
> On 12/15/18 12:03 AM, Mel Gorman wrote:
> > It's non-obvious that high-order free pages are split into order-0
> > pages from the function name. Fix it.
> 
> That's fine, but looks like the patch has another change squashed into
> it that removes zone parameter from several functions and uses cc->zone
> instead.
> 

Bah, it's a rebase mishap. It didn't flag when rereading the patches
before sending because "yep, I did that on purpose". I'll split it out,
the changelog will be uninspiring.

-- 
Mel Gorman
SUSE Labs
