Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id C24ED6B005D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 17:18:10 -0400 (EDT)
Received: by yenr5 with SMTP id r5so10994558yen.14
        for <linux-mm@kvack.org>; Thu, 02 Aug 2012 14:18:09 -0700 (PDT)
Date: Thu, 2 Aug 2012 14:18:07 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: Common [05/19] Move list_add() to slab_common.c
In-Reply-To: <20120802201533.204198847@linux.com>
Message-ID: <alpine.DEB.2.00.1208021417560.12259@chino.kir.corp.google.com>
References: <20120802201506.266817615@linux.com> <20120802201533.204198847@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

On Thu, 2 Aug 2012, Christoph Lameter wrote:

> Move the code to append the new kmem_cache to the list of slab caches to
> the kmem_cache_create code in the shared code.
> 
> This is possible now since the acquisition of the mutex was moved into
> kmem_cache_create().
> 
> Reviewed-by: Glauber Costa <glommer@parallels.com>
> Reviewed-by: Joonsoo Kim <js1304@gmail.com>
> Signed-off-by: Christoph Lameter <cl@linux.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
