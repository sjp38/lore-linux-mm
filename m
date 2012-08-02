Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 2D4246B004D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 10:34:29 -0400 (EDT)
Date: Thu, 2 Aug 2012 09:34:26 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Common [15/16] Shrink __kmem_cache_create() parameter lists
In-Reply-To: <alpine.DEB.2.00.1208020930190.23049@router.home>
Message-ID: <alpine.DEB.2.00.1208020933420.23049@router.home>
References: <20120801211130.025389154@linux.com> <20120801211204.342096542@linux.com> <501A57C2.2060702@parallels.com> <alpine.DEB.2.00.1208020930190.23049@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

On Thu, 2 Aug 2012, Christoph Lameter wrote:

> On Thu, 2 Aug 2012, Glauber Costa wrote:
>
> > > -		kfree(n);
> > > +		kfree(s->name);
> >
> > This last statement is a NULL pointer dereference.
>
> Yes. The statement should have been removed at the earlier patch where we
> move the allocation of the kmem_cache struct. sigh.

Arg. No the rearrangement is in this patch after all. So we can just drop
the statement.
xy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
