Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id F244B6B005A
	for <linux-mm@kvack.org>; Thu, 14 May 2009 16:23:03 -0400 (EDT)
Message-ID: <4A0C7DB6.6010601@redhat.com>
Date: Thu, 14 May 2009 16:23:18 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] zone_reclaim_mode is always 0 by default
References: <20090513120155.5879.A69D9226@jp.fujitsu.com> <20090513120729.5885.A69D9226@jp.fujitsu.com> <20090513152256.GM7601@sgi.com> <alpine.DEB.1.10.0905141602010.1381@qirst.com>
In-Reply-To: <alpine.DEB.1.10.0905141602010.1381@qirst.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Robin Holt <holt@sgi.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> Not having zone reclaim on a NUMA system often means that per node
> allocations will fall back. Optimized node local allocations become very
> difficult for the page allocator. If the latency penalties are not
> significant then this may not matter. The larger the system, the larger
> the NUMA latencies become.
> 
> One possibility would be to disable zone reclaim for low node numbers.
> Eanble it only if more than 4 nodes exist?

I suspect that patches 1/4 through 3/4 will cause the
system to behave better already, by only reclaiming
the easiest to reclaim pages from zone reclaim and
falling back after that - or am overlooking something?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
