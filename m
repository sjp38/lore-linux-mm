Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 46EC16B006C
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 17:45:25 -0500 (EST)
Message-ID: <50D3951E.50107@redhat.com>
Date: Thu, 20 Dec 2012 17:45:50 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: compaction: Do not accidentally skip pageblocks in
 the migrate scanner
References: <20121220142232.GA13367@suse.de>
In-Reply-To: <20121220142232.GA13367@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/20/2012 09:22 AM, Mel Gorman wrote:
> Compaction uses the ALIGN macro incorrectly with the migrate scanner by
> adding pageblock_nr_pages to a PFN. It happened to work when initially
> implemented as the starting PFN was also aligned but with caching restarts
> and isolating in smaller chunks this is no longer always true. The impact is
> that the migrate scanner scans outside its current pageblock. As pfn_valid()
> is still checked properly it does not cause any failure and the impact
> of the bug is that in some cases it will scan more than necessary when
> it crosses a page boundary but by no more than COMPACT_CLUSTER_MAX. It
> is highly unlikely this is even measurable but it's still wrong so this
> patch addresses the problem.
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
