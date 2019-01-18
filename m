Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 008BC8E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 04:18:00 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id v4so4607658edm.18
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 01:18:00 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v11si339433edj.211.2019.01.18.01.17.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 01:17:59 -0800 (PST)
Subject: Re: [PATCH 21/25] mm, compaction: Round-robin the order while
 searching the free lists for a target
References: <20190104125011.16071-1-mgorman@techsingularity.net>
 <20190104125011.16071-22-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <71ad4f46-ca81-9a70-0b98-d1a1c46df47a@suse.cz>
Date: Fri, 18 Jan 2019 10:17:58 +0100
MIME-Version: 1.0
In-Reply-To: <20190104125011.16071-22-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On 1/4/19 1:50 PM, Mel Gorman wrote:
> As compaction proceeds and creates high-order blocks, the free list
> search gets less efficient as the larger blocks are used as compaction
> targets. Eventually, the larger blocks will be behind the migration
> scanner for partially migrated pageblocks and the search fails. This
> patch round-robins what orders are searched so that larger blocks can be
> ignored and find smaller blocks that can be used as migration targets.
> 
> The overall impact was small on 1-socket but it avoids corner cases where
> the migration/free scanners meet prematurely or situations where many of
> the pageblocks encountered by the free scanner are almost full instead of
> being properly packed. Previous testing had indicated that without this
> patch there were occasional large spikes in the free scanner without this
> patch. By co-incidence, the 2-socket results showed a 54% reduction in
> the free scanner but will not be universally true.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>
