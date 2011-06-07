Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 1F05D6B0012
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 05:32:24 -0400 (EDT)
Date: Tue, 7 Jun 2011 10:32:19 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH]compaction: checks correct fragmentation index
Message-ID: <20110607093219.GB4372@csn.ul.ie>
References: <1307435801.15392.64.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1307435801.15392.64.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Jun 07, 2011 at 04:36:41PM +0800, Shaohua Li wrote:
> fragmentation_index() returns -1000 when the allocation might succeed
> This doesn't match the comment and code in compaction_suitable(). I
> thought compaction_suitable should return COMPACT_PARTIAL in -1000
> case, because in this case allocation could succeed depending on
> watermarks.
> 
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>

Well spotted. The impact of this is that compaction starts and
compact_finished() is called which rechecks the watermarks and the
free lists. It should have the same result in that compaction should
not start but is more expensive.

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
