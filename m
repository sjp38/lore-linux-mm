Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 8C44B6B004F
	for <linux-mm@kvack.org>; Sat, 16 May 2009 10:35:00 -0400 (EDT)
Message-ID: <4A0ECF1C.4010700@redhat.com>
Date: Sat, 16 May 2009 10:35:08 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] vmscan: merge duplicate code in shrink_active_list()
References: <20090516090005.916779788@intel.com> <20090516090448.535217680@intel.com>
In-Reply-To: <20090516090448.535217680@intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

Wu Fengguang wrote:
> The "move pages to active list" and "move pages to inactive list"
> code blocks are mostly identical and can be served by a function.
> 
> Thanks to Andrew Morton for pointing this out.
> 
> Note that buffer_heads_over_limit check will also be carried out
> for re-activated pages, which is slightly different from pre-2.6.28
> kernels. Also, Rik's "vmscan: evict use-once pages first" patch
> could totally stop scans of active list when memory pressure is low.
> So the net effect could be, the number of buffer heads is now more
> likely to grow large.
> 
> CC: Rik van Riel <riel@redhat.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
