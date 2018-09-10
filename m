Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D98D98E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 03:39:42 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id g11-v6so6633789edi.8
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 00:39:42 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k15-v6si1202401edb.253.2018.09.10.00.39.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 00:39:41 -0700 (PDT)
Date: Mon, 10 Sep 2018 09:39:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, thp: relax __GFP_THISNODE for MADV_HUGEPAGE mappings
Message-ID: <20180910073938.GA16723@dhcp22.suse.cz>
References: <20180907130550.11885-1-mhocko@kernel.org>
 <f7ed71c1-d599-5257-fd8f-041eb24d9f29@profihost.ag>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f7ed71c1-d599-5257-fd8f-041eb24d9f29@profihost.ag>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Zi Yan <zi.yan@cs.rutgers.edu>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

[Cc Vlastimil. The full report is http://lkml.kernel.org/r/f7ed71c1-d599-5257-fd8f-041eb24d9f29@profihost.ag]
On Sat 08-09-18 20:52:35, Stefan Priebe - Profihost AG wrote:
> [305146.987742] khugepaged: page allocation stalls for 224236ms, order:9,
> mode:0x4740ca(__GFP_HIGHMEM|__GFP_IO|__GFP_FS|__GFP_COMP|__GFP_NOMEMALLOC|__GFP_HARDWALL|__GFP_THISNODE|__GFP_MOVABLE|__GFP_DIRECT_RECLAIM), nodemask=(null)

This is certainly not a result of this patch AFAICS. khugepaged does add
__GFP_THISNODE regardless of what alloc_hugepage_khugepaged_gfpmask
thinks about that flag. Something to look into as well I guess.

Anyway, I guess we want to look closer at what compaction is doing here
because such a long stall is really not acceptable at all. Maybe this is
something 4.12 kernel related. This is hard to tell. Unfortunatelly,
upstream has lost the stall warning so you wouldn't know this is the
case with newer kernels.

Anyway, running with compaction tracepoints might tell us more.
Vlastimil will surely help to tell you which of them to enable.
-- 
Michal Hocko
SUSE Labs
