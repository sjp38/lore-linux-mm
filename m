Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id F07226B005C
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 22:36:08 -0400 (EDT)
Message-ID: <4FF3AC42.2000503@kernel.org>
Date: Wed, 04 Jul 2012 11:36:50 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] mm: minor fixes for compaction
References: <20120628135520.0c48b066@annuminas.surriel.com> <4FECE844.2050803@kernel.org> <20120703161304.7734fbef@annuminas.surriel.com>
In-Reply-To: <20120703161304.7734fbef@annuminas.surriel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, jaschut@sandia.gov, kamezawa.hiroyu@jp.fujitsu.com

On 07/04/2012 05:13 AM, Rik van Riel wrote:

> This patch makes the comment for cc->wrapped longer, explaining
> what is really going on. It also incorporates the comment fix
> pointed out by Minchan.
> 
> Additionally, Minchan found that, when no pages get isolated,
> high_pte could be a value that is much lower than desired,
> which might potentially cause compaction to skip a range of
> pages.
> 
> Only assign zone->compact_cache_free_pfn if we actually
> isolated free pages for compaction.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>


Reviewed-by: Minchan Kim <minchan@kernel.org>

> ---
> This does not address the one bit in Minchan's review that I am not sure about...


About this part, let's wait of Mel's opinion.

Thanks.
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
