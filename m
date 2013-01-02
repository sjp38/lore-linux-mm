Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 658976B0078
	for <linux-mm@kvack.org>; Wed,  2 Jan 2013 11:03:02 -0500 (EST)
Date: Wed, 2 Jan 2013 16:03:01 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/3] slub: remove slab_alloc wrapper
In-Reply-To: <1355925702-7537-3-git-send-email-glommer@parallels.com>
Message-ID: <0000013bfc005f2d-96a7ff69-35d5-4b93-ac3d-f5aa67eeae4e-000000@email.amazonses.com>
References: <1355925702-7537-1-git-send-email-glommer@parallels.com> <1355925702-7537-3-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Dave Shrinnker <david@fromorbit.com>, Michal Hocko <mhocko@suse.cz>, kamezawa.hiroyu@jp.fujitsu.com, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Wed, 19 Dec 2012, Glauber Costa wrote:

> Being slab_alloc such a simple and unconditional wrapper around
> slab_alloc_node, we should get rid of it for simplicity, patching
> the callers directly.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
