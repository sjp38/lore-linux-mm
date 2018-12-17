Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 92BB48E0001
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 08:20:31 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id r16so10619788pgr.15
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 05:20:31 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y6si11111404pfi.228.2018.12.17.05.20.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 05:20:30 -0800 (PST)
Subject: Re: [PATCH 02/14] mm, compaction: Rearrange compact_control
References: <20181214230310.572-1-mgorman@techsingularity.net>
 <20181214230310.572-3-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <85aad977-efdd-91ff-8e71-4f17b4695cf2@suse.cz>
Date: Mon, 17 Dec 2018 14:20:28 +0100
MIME-Version: 1.0
In-Reply-To: <20181214230310.572-3-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On 12/15/18 12:02 AM, Mel Gorman wrote:
> compact_control spans two cache lines with write-intensive lines on
> both. Rearrange so the most write-intensive fields are in the same
> cache line. This has a negligible impact on the overall performance of
> compaction and is more a tidying exercise than anything.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>
