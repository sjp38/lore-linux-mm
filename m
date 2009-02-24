Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7AC056B00C7
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 12:40:38 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 3B04A82C443
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 12:44:52 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id gQa3Ew+fzt3N for <linux-mm@kvack.org>;
	Tue, 24 Feb 2009 12:44:47 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 8FD1382C3D6
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 12:44:47 -0500 (EST)
Date: Tue, 24 Feb 2009 12:31:41 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 10/19] Calculate the preferred zone for allocation only
 once
In-Reply-To: <1235477835-14500-11-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0902241229450.32227@qirst.com>
References: <1235477835-14500-1-git-send-email-mel@csn.ul.ie> <1235477835-14500-11-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Feb 2009, Mel Gorman wrote:

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6f26944..074f9a6 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1399,24 +1399,19 @@ static void zlc_mark_zone_full(struct zonelist *zonelist, struct zoneref *z)
>   */
>  static struct page *
>  get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
> -		struct zonelist *zonelist, int high_zoneidx, int alloc_flags)
> +		struct zonelist *zonelist, int high_zoneidx, int alloc_flags,
> +		struct zone *preferred_zone)
>  {

This gets into a quite a number of parameters now. Pass a structure like in
vmscan.c? Or simplify things to be able to run get_page_from_freelist with
less parameters? The number of parameters seem to be too high for a
fastpath function.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
