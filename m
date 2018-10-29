Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A723D6B0368
	for <linux-mm@kvack.org>; Mon, 29 Oct 2018 06:08:37 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c2-v6so5318279edi.6
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 03:08:37 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l9si270271edv.432.2018.10.29.03.08.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Oct 2018 03:08:36 -0700 (PDT)
Date: Mon, 29 Oct 2018 11:08:34 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: thp:  relax __GFP_THISNODE for MADV_HUGEPAGE
 mappings
Message-ID: <20181029100834.GG32673@dhcp22.suse.cz>
References: <20180925120326.24392-1-mhocko@kernel.org>
 <20180925120326.24392-2-mhocko@kernel.org>
 <20181029051752.GB16399@350D>
 <20181029090035.GE32673@dhcp22.suse.cz>
 <20181029094253.GC16399@350D>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181029094253.GC16399@350D>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Stable tree <stable@vger.kernel.org>

On Mon 29-10-18 20:42:53, Balbir Singh wrote:
> On Mon, Oct 29, 2018 at 10:00:35AM +0100, Michal Hocko wrote:
[...]
> > These hugetlb allocations might be disruptive and that is an expected
> > behavior because this is an explicit requirement from an admin to
> > pre-allocate large pages for the future use. __GFP_RETRY_MAYFAIL just
> > underlines that requirement.
> 
> Yes, but in the absence of a particular node, for example via sysctl
> (as the compaction does), I don't think it is a hard requirement to get
> a page from a particular node.

Again this seems like a deliberate decision. You want your distributions
as even as possible otherwise the NUMA placement will be much less
deterministic. At least that was the case for a long time. If you
have different per-node preferences, just use NUMA aware pre-allocation.

> I agree we need __GFP_RETRY_FAIL, in any
> case the real root cause for me is should_reclaim_continue() which keeps
> the task looping without making forward progress.

This seems like a separate issue which should better be debugged. Please
open a new thread describing the problem and the state of the node.

-- 
Michal Hocko
SUSE Labs
