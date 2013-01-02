Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id BFFEC6B007D
	for <linux-mm@kvack.org>; Wed,  2 Jan 2013 11:10:22 -0500 (EST)
Date: Wed, 2 Jan 2013 16:10:21 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/3] sl[auo]b: retry allocation once in case of
 failure.
In-Reply-To: <1355925702-7537-4-git-send-email-glommer@parallels.com>
Message-ID: <0000013bfc071798-e09146e7-8c3c-41be-a700-1676fd418e59-000000@email.amazonses.com>
References: <1355925702-7537-1-git-send-email-glommer@parallels.com> <1355925702-7537-4-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Dave Shrinnker <david@fromorbit.com>, Michal Hocko <mhocko@suse.cz>, kamezawa.hiroyu@jp.fujitsu.com, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Wed, 19 Dec 2012, Glauber Costa wrote:

> When we are out of space in the caches, we will try to allocate a new
> page.  If we still fail, the page allocator will try to free pages
> through direct reclaim. Which means that if an object allocation failed
> we can be sure that no new pages could be given to us, even though
> direct reclaim was likely invoked.

Well this hits the hot allocation path with lots of additional checks
that also require the touching of more cachelines.

How much impact will this have?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
