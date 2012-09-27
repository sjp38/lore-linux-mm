Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id B9C926B0068
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 18:51:02 -0400 (EDT)
Received: by pbbrq2 with SMTP id rq2so4776435pbb.14
        for <linux-mm@kvack.org>; Thu, 27 Sep 2012 15:51:02 -0700 (PDT)
Date: Thu, 27 Sep 2012 15:50:58 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slab: Ignore internal flags in cache creation
In-Reply-To: <0000013a08020b4d-ecc22fc9-75e4-4f1d-8a76-5496a98d1df9-000000@email.amazonses.com>
Message-ID: <alpine.DEB.2.00.1209271546460.13360@chino.kir.corp.google.com>
References: <1348571866-31738-1-git-send-email-glommer@parallels.com> <00000139fe408877-40bc98e3-322c-4ba2-be72-e298ff28e694-000000@email.amazonses.com> <alpine.DEB.2.00.1209251744580.22521@chino.kir.corp.google.com> <5062C029.308@parallels.com>
 <alpine.DEB.2.00.1209261813300.7072@chino.kir.corp.google.com> <0000013a08020b4d-ecc22fc9-75e4-4f1d-8a76-5496a98d1df9-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@cs.helsinki.fi>

On Thu, 27 Sep 2012, Christoph Lameter wrote:

> > I would suggest cachep->flags being used solely for the flags passed to
> > kmem_cache_create() and seperating out all "internal flags" based on the
> > individual slab allocator's implementation into a different field.  There
> > should be no problem with moving CFLGS_OFF_SLAB elsewhere, in fact, I just
> > removed a "dflags" field from mm/slab.c's kmem_cache that turned out never
> > to be used.  You could simply reintroduce a new "internal_flags" field and
> > use it at your discretion.
> 
> This means touching another field from critical paths of the allocators.
> It would increase the cache footprint and therefore reduce performance.
> 

To clarify your statement, you're referring to the mm/slab.c allocation of 
new slab pages and when debugging is enabled as "critical paths", correct?  
We would disagree on that point.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
