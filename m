Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9696E8E0001
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 07:27:23 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id y35so8609421edb.5
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 04:27:23 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z5-v6si4258094ejp.317.2018.12.17.04.27.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 04:27:22 -0800 (PST)
Subject: Re: [PATCH 01/14] mm, compaction: Shrink compact_control
References: <20181214230310.572-1-mgorman@techsingularity.net>
 <20181214230310.572-2-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <f1bb7787-3626-1212-5d6d-a6c6aec81fa4@suse.cz>
Date: Mon, 17 Dec 2018 13:27:20 +0100
MIME-Version: 1.0
In-Reply-To: <20181214230310.572-2-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Linux-MM <linux-mm@kvack.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On 12/15/18 12:02 AM, Mel Gorman wrote:
> The isolate and migrate scanners should never isolate more than a pageblock
> of pages so unsigned int is sufficient saving 8 bytes on a 64-bit build.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/internal.h | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/internal.h b/mm/internal.h
> index 536bc2a839b9..5564841fce36 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -185,8 +185,8 @@ struct compact_control {
>  	struct list_head freepages;	/* List of free pages to migrate to */
>  	struct list_head migratepages;	/* List of pages being migrated */
>  	struct zone *zone;
> -	unsigned long nr_freepages;	/* Number of isolated free pages */
> -	unsigned long nr_migratepages;	/* Number of pages to migrate */
> +	unsigned int nr_freepages;	/* Number of isolated free pages */
> +	unsigned int nr_migratepages;	/* Number of pages to migrate */
>  	unsigned long total_migrate_scanned;
>  	unsigned long total_free_scanned;
>  	unsigned long free_pfn;		/* isolate_freepages search base */
> 
