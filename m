Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 316D66B0070
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 16:45:33 -0400 (EDT)
Date: Tue, 23 Oct 2012 20:45:31 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: CK2 [01/15] slab: Simplify bootstrap
In-Reply-To: <5084FC73.1030302@parallels.com>
Message-ID: <0000013a8f5f7ff1-2bdb767b-9c75-4a43-8df1-ed216b902b05-000000@email.amazonses.com>
References: <20121019142254.724806786@linux.com> <0000013a796a77f9-b0c5beb7-21e0-4e62-bc08-5b909617f678-000000@email.amazonses.com> <5084FC73.1030302@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

On Mon, 22 Oct 2012, Glauber Costa wrote:

> With nodelists being part of kmem_cache, and kmem_cache being allocated
> with kmem_cache_zalloc, it seems to me that you can actually just get
> rid of the inner loop instead of patching it. But this is orthogonal to
> this patch...

Ok Will fix that... Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
