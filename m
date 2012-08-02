Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 3130C6B008A
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 16:58:09 -0400 (EDT)
Received: by yenr5 with SMTP id r5so10968277yen.14
        for <linux-mm@kvack.org>; Thu, 02 Aug 2012 13:58:08 -0700 (PDT)
Date: Thu, 2 Aug 2012 13:58:05 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: Common [04/19] Improve error handling in kmem_cache_create
In-Reply-To: <20120802201532.623330251@linux.com>
Message-ID: <alpine.DEB.2.00.1208021357110.5454@chino.kir.corp.google.com>
References: <20120802201506.266817615@linux.com> <20120802201532.623330251@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

On Thu, 2 Aug 2012, Christoph Lameter wrote:

> Instead of using s == NULL use an errorcode. This allows much more
> detailed diagnostics as to what went wrong. As we add more functionality
> from the slab allocators to the common kmem_cache_create() function we will
> also add more error conditions.
> 
> Print the error code during the panic as well as in a warning if the module
> can handle failure. The API for kmem_cache_create() currently does not allow
> the returning of an error code. Return NULL but log the cause of the problem
> in the syslog.
> 

I like how this also dumps the stack for any kmem_cache_create() that 
fails.

> Signed-off-by: Christoph Lameter <cl@linux.com>
> 

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
