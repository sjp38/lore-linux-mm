Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id A4D0F6B0031
	for <linux-mm@kvack.org>; Wed,  4 Sep 2013 19:58:37 -0400 (EDT)
Message-ID: <5227C928.8080709@redhat.com>
Date: Wed, 04 Sep 2013 19:58:32 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch] mm, compaction: periodically schedule when freeing pages
References: <alpine.DEB.2.02.1309041625060.29607@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1309041625060.29607@chino.kir.corp.google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 09/04/2013 07:25 PM, David Rientjes wrote:
> We've been getting warnings about an excessive amount of time spent
> allocating pages for migration during memory compaction without
> scheduling.  isolate_freepages_block() already periodically checks for
> contended locks or the need to schedule, but isolate_freepages() never
> does.
> 
> When a zone is massively long and no suitable targets can be found, this
> iteration can be quite expensive without ever doing cond_resched().
> 
> Check periodically for the need to reschedule while the compaction free
> scanner iterates.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
