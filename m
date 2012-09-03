Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 7FD166B0062
	for <linux-mm@kvack.org>; Mon,  3 Sep 2012 11:06:05 -0400 (EDT)
Message-ID: <5044C69E.3070704@parallels.com>
Date: Mon, 3 Sep 2012 19:02:54 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: C13 [09/14] Move duping of slab name to slab_common.c
References: <20120824160903.168122683@linux.com> <00000139596ca258-6eb54dde-2278-4694-b562-5e02d5530419-000000@email.amazonses.com>
In-Reply-To: <00000139596ca258-6eb54dde-2278-4694-b562-5e02d5530419-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On 08/24/2012 08:17 PM, Christoph Lameter wrote:
> Duping of the slabname has to be done by each slab. Moving this code
> to slab_common avoids duplicate implementations.
> 
> With this patch we have common string handling for all slab allocators.
> Strings passed to kmem_cache_create() are copied internally. Subsystems
> can create temporary strings to create slab caches.
> 
> Slabs allocated in early states of bootstrap will never be freed (and those
> can never be freed since they are essential to slab allocator operations).
> During bootstrap we therefore do not have to worry about duping names.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

This version fixes all the problems I've raised before.

I've also boot-tested and applied my previous repeated
kmem_cache_destroy() test and it seems to survive well.

Reviewed-by: Glauber Costa <glommer@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
