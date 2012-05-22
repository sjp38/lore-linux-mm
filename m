Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 921AE6B0083
	for <linux-mm@kvack.org>; Tue, 22 May 2012 09:56:50 -0400 (EDT)
Date: Tue, 22 May 2012 08:56:47 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slab+slob: dup name string
In-Reply-To: <alpine.DEB.2.00.1205212018230.13522@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1205220855470.17600@router.home>
References: <1337613539-29108-1-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1205212018230.13522@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Glauber Costa <glommer@parallels.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>

On Mon, 21 May 2012, David Rientjes wrote:

> This doesn't work if you kmem_cache_destroy() a cache that was created
> when g_cpucache_cpu <= EARLY, the kfree() will explode.  That never
> happens for any existing cache created in kmem_cache_init(), but this
> would introduce the first roadblock in doing so.  So you'll need some
> magic to determine whether the cache was allocated statically and suppress
> the kfree() in such a case.

Nope. Only slab management caches will be created that early. The patch is
fine as is.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
