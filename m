Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 35B716B004D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 09:02:07 -0400 (EDT)
Message-ID: <501A7A49.6070506@parallels.com>
Date: Thu, 2 Aug 2012 17:02:01 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [question] how to increase the number of object on cache?
References: <5F2C6DA655B36C43B21C7FB179CEC9F4E3F157BDEE@HKMAIL02.nvidia.com> <501A77A4.1050005@parallels.com> <5F2C6DA655B36C43B21C7FB179CEC9F4E3F157BDF1@HKMAIL02.nvidia.com>
In-Reply-To: <5F2C6DA655B36C43B21C7FB179CEC9F4E3F157BDF1@HKMAIL02.nvidia.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shawn Joo <sjoo@nvidia.com>
Cc: "cl@linux-foundation.org" <cl@linux-foundation.org>, "penberg@kernel.org" <penberg@kernel.org>, "mpm@selenic.com" <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 08/02/2012 04:55 PM, Shawn Joo wrote:
>>> then yes, they will allocate the necessary number of pages from the standard page allocator.
> Who is "the standard page allocator" for cache in /proc/slabinfo, e.g. "size-65536" ?
> I believe one of allocator is buddy. who else?
> 
The generic and algorithm-neutral answer to this is "whoever would
handle alloc_pages()".
In the specific case, yes, this is the buddy allocator.

Take a look at mm/slab.c, for instance:

When a cache can't service an allocation, it does:

  cache_grow()
  -> kmem_getpages()
    -> alloc_pages_exact_node()


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
