Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9099A6B01E3
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 19:36:34 -0400 (EDT)
Message-ID: <4BC65237.5080408@kernel.org>
Date: Thu, 15 Apr 2010 08:39:35 +0900
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/6] change alloc function in pcpu_alloc_pages
References: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com> <d5d70d4b57376bc89f178834cf0e424eaa681ab4.1271171877.git.minchan.kim@gmail.com> <20100413154820.GC25756@csn.ul.ie>
In-Reply-To: <20100413154820.GC25756@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hello,

On 04/14/2010 12:48 AM, Mel Gorman wrote:
> and the mapping table on x86 at least is based on possible CPUs in
> init_cpu_to_node() leaves the mapping as 0 if the APIC is bad or the numa
> node is reported in apicid_to_node as -1. It would appear on power that
> the node will be 0 for possible CPUs as well.
> 
> Hence, I believe this to be safe but a confirmation from Tejun would be
> nice. I would continue digging but this looks like an initialisation path
> so I'll move on to the next patch rather than spending more time.

This being a pretty cold path, I don't really see much benefit in
converting it to alloc_pages_node_exact().  It ain't gonna make any
difference.  I'd rather stay with the safer / boring one unless
there's a pressing reason to convert.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
