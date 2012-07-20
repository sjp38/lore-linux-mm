Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 04F6A6B0044
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 18:19:52 -0400 (EDT)
Message-ID: <5009D8D8.6040509@parallels.com>
Date: Fri, 20 Jul 2012 19:16:56 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 24/25] memcg/slub: shrink dead caches
References: <1340015298-14133-1-git-send-email-glommer@parallels.com> <1340015298-14133-25-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1207061015030.28648@router.home>
In-Reply-To: <alpine.DEB.2.00.1207061015030.28648@router.home>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, cgroups@vger.kernel.org, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Suleiman Souhlal <suleiman@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

On 07/06/2012 12:16 PM, Christoph Lameter wrote:
> On Mon, 18 Jun 2012, Glauber Costa wrote:
> 
>> In the slub allocator, when the last object of a page goes away, we
>> don't necessarily free it - there is not necessarily a test for empty
>> page in any slab_free path.
> 
> This is the same btw in SLAB which keeps objects in per cpu caches and
> keeps empty slab pages on special queues.
> 
>> This patch marks all memcg caches as dead. kmem_cache_shrink is called
>> for the ones who are not yet dead - this will force internal cache
>> reorganization, and then all references to empty pages will be removed.
> 
> You need to call this also for slab to drain the caches and free the pages
> on the empty list.
> 
Doesn't the SLAB have a time-based reaper for that?

That's why I was less concerned with the SLAB, but I can certainly call
it for both.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
