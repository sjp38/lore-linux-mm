Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 44D7D6B005D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 10:15:24 -0400 (EDT)
Date: Thu, 2 Aug 2012 09:15:21 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Common [14/16] Move kmem_cache allocations into common code.
In-Reply-To: <501A5751.4000800@parallels.com>
Message-ID: <alpine.DEB.2.00.1208020915000.23049@router.home>
References: <20120801211130.025389154@linux.com> <20120801211203.783229289@linux.com> <501A5751.4000800@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

On Thu, 2 Aug 2012, Glauber Costa wrote:

> On 08/02/2012 01:11 AM, Christoph Lameter wrote:
> >
> >  	if (setup_cpu_cache(cachep, gfp)) {
> >  		__kmem_cache_shutdown(cachep);
> > -		return NULL;
> > +		return -ENOSPC;
> >  	}
>
> Are we reading anything from disk here ?

Nope. I was just at a loss to find a return code.

> Besides that, setup_cpu_cache() itself returns an error. It would be a
> lot better to just use it, instead of replacing it with our own
> interpretation of it

Ok.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
