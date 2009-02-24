Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 78D686B00C5
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 12:35:33 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 432A682C454
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 12:40:11 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id zDsPERLw8m1T for <linux-mm@kvack.org>;
	Tue, 24 Feb 2009 12:40:06 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 99EF482C43D
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 12:40:06 -0500 (EST)
Date: Tue, 24 Feb 2009 12:27:02 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 08/19] Simplify the check on whether cpusets are a factor
 or not
In-Reply-To: <1235477835-14500-9-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0902241226280.32227@qirst.com>
References: <1235477835-14500-1-git-send-email-mel@csn.ul.ie> <1235477835-14500-9-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Feb 2009, Mel Gorman wrote:

> @@ -1420,8 +1429,8 @@ zonelist_scan:
>  		if (NUMA_BUILD && zlc_active &&
>  			!zlc_zone_worth_trying(zonelist, z, allowednodes))
>  				continue;
> -		if ((alloc_flags & ALLOC_CPUSET) &&
> -			!cpuset_zone_allowed_softwall(zone, gfp_mask))
> +		if (alloc_cpuset)
> +			if (!cpuset_zone_allowed_softwall(zone, gfp_mask))
>  				goto try_next_zone;

Hmmm... Why remove the && here? Looks more confusing to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
