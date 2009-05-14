Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0514F6B0083
	for <linux-mm@kvack.org>; Thu, 14 May 2009 16:05:09 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 2F8CE82C37D
	for <linux-mm@kvack.org>; Thu, 14 May 2009 16:18:00 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id tKjlc-hDsbpr for <linux-mm@kvack.org>;
	Thu, 14 May 2009 16:18:00 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id C397D82C381
	for <linux-mm@kvack.org>; Thu, 14 May 2009 16:17:55 -0400 (EDT)
Date: Thu, 14 May 2009 16:05:07 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 4/4] zone_reclaim_mode is always 0 by default
In-Reply-To: <20090513152256.GM7601@sgi.com>
Message-ID: <alpine.DEB.1.10.0905141602010.1381@qirst.com>
References: <20090513120155.5879.A69D9226@jp.fujitsu.com> <20090513120729.5885.A69D9226@jp.fujitsu.com> <20090513152256.GM7601@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Robin Holt <holt@sgi.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>


Not having zone reclaim on a NUMA system often means that per node
allocations will fall back. Optimized node local allocations become very
difficult for the page allocator. If the latency penalties are not
significant then this may not matter. The larger the system, the larger
the NUMA latencies become.

One possibility would be to disable zone reclaim for low node numbers.
Eanble it only if more than 4 nodes exist?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
