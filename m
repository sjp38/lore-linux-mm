Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 12A5B8E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 12:17:31 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id x15so3977838edd.2
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 09:17:31 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i25si5462011edb.334.2019.01.17.09.17.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 09:17:29 -0800 (PST)
Subject: Re: [PATCH 17/25] mm, compaction: Keep cached migration PFNs synced
 for unusable pageblocks
References: <20190104125011.16071-1-mgorman@techsingularity.net>
 <20190104125011.16071-18-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <2e384ff6-a4fd-5047-428d-b90cfa95be2e@suse.cz>
Date: Thu, 17 Jan 2019 18:17:28 +0100
MIME-Version: 1.0
In-Reply-To: <20190104125011.16071-18-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On 1/4/19 1:50 PM, Mel Gorman wrote:
> Migrate has separate cached PFNs for ASYNC and SYNC* migration on the
> basis that some migrations will fail in ASYNC mode. However, if the cached
> PFNs match at the start of scanning and pageblocks are skipped due to
> having no isolation candidates, then the sync state does not matter.
> This patch keeps matching cached PFNs in sync until a pageblock with
> isolation candidates is found.
> 
> The actual benefit is marginal given that the sync scanner following the
> async scanner will often skip a number of pageblocks but it's useless
> work. Any benefit depends heavily on whether the scanners restarted
> recently so overall the reduction in scan rates is a mere 2.8% which
> is borderline noise.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

My easlier suggestion to check more thoroughly if pages can be migrated (which
depends on the mode) before isolating them wouldn't play nice with this :)
