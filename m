Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D79048E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 04:23:56 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id y35so11951661edb.5
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 01:23:56 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g21si5237277edj.72.2018.12.18.01.23.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Dec 2018 01:23:55 -0800 (PST)
Subject: Re: [PATCH 07/14] mm, compaction: Always finish scanning of a full
 pageblock
References: <20181214230310.572-1-mgorman@techsingularity.net>
 <20181214230310.572-8-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d0b6cb2d-a5cd-b415-e56f-2ad145f86cbc@suse.cz>
Date: Tue, 18 Dec 2018 10:23:54 +0100
MIME-Version: 1.0
In-Reply-To: <20181214230310.572-8-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On 12/15/18 12:03 AM, Mel Gorman wrote:
> When compaction is finishing, it uses a flag to ensure the pageblock is
> complete.  However, in general it makes sense to always complete migration
> of a pageblock. Minimally, skip information is based on a pageblock and
> partially scanned pageblocks may incur more scanning in the future. The
> pageblock skip handling also becomes more strict later in the series and
> the hint is more useful if a complete pageblock was always scanned.
> 
> The impact here is potentially on latencies as more scanning is done
> but it's not a consistent win or loss as the scanning is not always a
> high percentage of the pageblock and sometimes it is offset by future
> reductions in scanning. Hence, the results are not presented this time as
> it's a mix of gains/losses without any clear pattern. However, completing
> scanning of the pageblock is important for later patches.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>
