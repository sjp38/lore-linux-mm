Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 065186B00D6
	for <linux-mm@kvack.org>; Tue, 18 Sep 2012 11:20:12 -0400 (EDT)
Date: Tue, 18 Sep 2012 15:20:11 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3 03/16] slab: Ignore the cflgs bit in cache creation
In-Reply-To: <1347977530-29755-4-git-send-email-glommer@parallels.com>
Message-ID: <00000139d9f7127d-c812558e-aa71-44b4-9629-d33cadba9929-000000@email.amazonses.com>
References: <1347977530-29755-1-git-send-email-glommer@parallels.com> <1347977530-29755-4-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Tue, 18 Sep 2012, Glauber Costa wrote:

> No cache should ever pass that as a creation flag, since this bit is
> used to mark an internal decision of the slab about object placement. We
> can just ignore this bit if it happens to be passed (such as when
> duplicating a cache in the kmem memcg patches)

If we do this then I would like to see a general masking of internal
allocator bits in kmem_cache_create. We could declare the highest byte to
be the internal slab flags. SLUB uses two flags in that area. SLAB uses
one.

F.e. add

#define SLAB_INTERNAL 0xFF00000000UL

to slab.h.

Then the flags can then be masked in mm/slab_common.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
