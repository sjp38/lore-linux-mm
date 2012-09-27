Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id D0FAA6B0044
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 09:54:44 -0400 (EDT)
Date: Thu, 27 Sep 2012 13:54:43 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slab: Ignore internal flags in cache creation
In-Reply-To: <alpine.DEB.2.00.1209261813300.7072@chino.kir.corp.google.com>
Message-ID: <0000013a08020b4d-ecc22fc9-75e4-4f1d-8a76-5496a98d1df9-000000@email.amazonses.com>
References: <1348571866-31738-1-git-send-email-glommer@parallels.com> <00000139fe408877-40bc98e3-322c-4ba2-be72-e298ff28e694-000000@email.amazonses.com> <alpine.DEB.2.00.1209251744580.22521@chino.kir.corp.google.com> <5062C029.308@parallels.com>
 <alpine.DEB.2.00.1209261813300.7072@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@cs.helsinki.fi>

On Wed, 26 Sep 2012, David Rientjes wrote:

> I would suggest cachep->flags being used solely for the flags passed to
> kmem_cache_create() and seperating out all "internal flags" based on the
> individual slab allocator's implementation into a different field.  There
> should be no problem with moving CFLGS_OFF_SLAB elsewhere, in fact, I just
> removed a "dflags" field from mm/slab.c's kmem_cache that turned out never
> to be used.  You could simply reintroduce a new "internal_flags" field and
> use it at your discretion.

This means touching another field from critical paths of the allocators.
It would increase the cache footprint and therefore reduce performance.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
