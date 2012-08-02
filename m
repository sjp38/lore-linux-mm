Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 52F4E6B004D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 10:11:43 -0400 (EDT)
Date: Thu, 2 Aug 2012 09:11:40 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Common [15/16] Shrink __kmem_cache_create() parameter lists
In-Reply-To: <501A381F.9040703@parallels.com>
Message-ID: <alpine.DEB.2.00.1208020910450.23049@router.home>
References: <20120801211130.025389154@linux.com> <20120801211204.342096542@linux.com> <501A381F.9040703@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

On Thu, 2 Aug 2012, Glauber Costa wrote:

> On 08/02/2012 01:11 AM, Christoph Lameter wrote:
> > +		if (!s->name) {
> > +			kmem_cache_free(kmem_cache, s);
> > +			s = NULL;
> > +			goto oops;
> > +		}
> > +
> This is now only defined when CONFIG_DEBUG_VM. Now would be a good time
> to fix that properly by just removing the ifdef around the label.

I disagree with randomly adding checks to production code. These are
things useful for debugging but should not increase the cahce footprint of
the kernel in production system.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
