Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 2A9506B005A
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 10:31:15 -0400 (EDT)
Date: Thu, 2 Aug 2012 09:31:12 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Common [15/16] Shrink __kmem_cache_create() parameter lists
In-Reply-To: <501A57C2.2060702@parallels.com>
Message-ID: <alpine.DEB.2.00.1208020930190.23049@router.home>
References: <20120801211130.025389154@linux.com> <20120801211204.342096542@linux.com> <501A57C2.2060702@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

On Thu, 2 Aug 2012, Glauber Costa wrote:

> > -		kfree(n);
> > +		kfree(s->name);
>
> This last statement is a NULL pointer dereference.

Yes. The statement should have been removed at the earlier patch where we
move the allocation of the kmem_cache struct. sigh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
