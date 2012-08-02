Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 414536B004D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 10:14:01 -0400 (EDT)
Date: Thu, 2 Aug 2012 09:13:58 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Common [09/16] Do slab aliasing call from common code
In-Reply-To: <501A4892.5090809@parallels.com>
Message-ID: <alpine.DEB.2.00.1208020913370.23049@router.home>
References: <20120801211130.025389154@linux.com> <20120801211200.655711830@linux.com> <501A4892.5090809@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

On Thu, 2 Aug 2012, Glauber Costa wrote:

> On 08/02/2012 01:11 AM, Christoph Lameter wrote:
> > +	s = __kmem_cache_alias(name, size, align, flags, ctor);
> > +	if (s)
> > +		goto oops;
> > +
>
> "goto oops" is a really bad way of naming a branch conditional to a
> perfectly valid state.

True. Will change to "out" or something.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
