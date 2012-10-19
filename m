Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id DEC996B0069
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 15:44:51 -0400 (EDT)
Date: Fri, 19 Oct 2012 19:44:49 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v5 10/18] sl[au]b: always get the cache from its page in
 kfree
In-Reply-To: <1350656442-1523-11-git-send-email-glommer@parallels.com>
Message-ID: <0000013a7a8e764d-5cef2c85-993f-4600-85c7-ce3fe137f16f-000000@email.amazonses.com>
References: <1350656442-1523-1-git-send-email-glommer@parallels.com> <1350656442-1523-11-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, devel@openvz.org, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On Fri, 19 Oct 2012, Glauber Costa wrote:

> struct page already have this information. If we start chaining
> caches, this information will always be more trustworthy than
> whatever is passed into the function

Yes it does but the information is not standardized between the allocators
yet. Coul you unify that? Come out with a struct page overlay that is as
much the same as possible. Then kfree can also be unified because the
lookup is always the same. That way you can move kfree into slab_common
and avoid modifying multiple allocators.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
