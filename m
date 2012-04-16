Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id C052C6B00EF
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 10:02:10 -0400 (EDT)
Date: Mon, 16 Apr 2012 09:02:07 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: don't create a copy of the name string in
 kmem_cache_create
In-Reply-To: <1334351170-26672-1-git-send-email-glommer@parallels.com>
Message-ID: <alpine.DEB.2.00.1204160900270.7795@router.home>
References: <1334351170-26672-1-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, devel@openvz.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>

On Fri, 13 Apr 2012, Glauber Costa wrote:

> When creating a cache, slub keeps a copy of the cache name through
> strdup. The slab however, doesn't do that. This means that everyone
> registering caches have to keep a copy themselves anyway, since code
> needs to work on all allocators.
>
> Having slab create a copy of it as well may very well be the right
> thing to do: but at this point, the callers are already there

What would break if we would add that to slab? I think this is more robust
because right now slab relies on the caller not freeing the string.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
