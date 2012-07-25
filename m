Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 925646B0073
	for <linux-mm@kvack.org>; Wed, 25 Jul 2012 14:19:30 -0400 (EDT)
Message-ID: <50103802.1070700@parallels.com>
Date: Wed, 25 Jul 2012 22:16:34 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 10/10] memcg/sl[au]b: shrink dead caches
References: <1343227101-14217-1-git-send-email-glommer@parallels.com> <1343227101-14217-11-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1207251207180.3543@router.home>
In-Reply-To: <alpine.DEB.2.00.1207251207180.3543@router.home>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Frederic Weisbecker <fweisbec@gmail.com>, devel@openvz.org, cgroups@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Suleiman Souhlal <suleiman@google.com>

On 07/25/2012 09:13 PM, Christoph Lameter wrote:
> On Wed, 25 Jul 2012, Glauber Costa wrote:
> 
>> In the slub allocator, when the last object of a page goes away, we
>> don't necessarily free it - there is not necessarily a test for empty
>> page in any slab_free path.
> 
> That is true for the slab allocator as well. In either case calling
> kmem_cache_shrink() will make the objects go away by draining the cached
> objects and freeing the pages used for the objects back to the page
> allocator. You do not need this patch. Just call the proper functions to
> drop the objecgts in the caches in either allocator.
> 
>> The slab allocator has a time based reaper that would eventually get rid
>> of the objects, but we can also call it explicitly, since dead caches
>> are not a likely event.
> 
> So this is already for both allocators?
> 
Yes, I just didn't updated the whole changelog. my bad.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
