Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 8196F6B005D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 09:50:12 -0400 (EDT)
Date: Thu, 2 Aug 2012 15:50:07 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [question] how to increase the number of object on cache?
Message-ID: <20120802135007.GB18089@dhcp22.suse.cz>
References: <5F2C6DA655B36C43B21C7FB179CEC9F4E3F157BDEE@HKMAIL02.nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5F2C6DA655B36C43B21C7FB179CEC9F4E3F157BDEE@HKMAIL02.nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shawn Joo <sjoo@nvidia.com>
Cc: "cl@linux-foundation.org" <cl@linux-foundation.org>, "penberg@kernel.org" <penberg@kernel.org>, "mpm@selenic.com" <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu 02-08-12 20:20:25, Shawn Joo wrote:
> Dear Experts,
> 
> I would like to know a mechanism, how to increase the number of object and where the memory is from.
> 
> (because when cache is created by "kmem_cache_create", there is only object size, but no number of the object)
> For example, "size-65536" does not have available memory from below dump.
> In that state, if memory allocation is requested to "size-65536",

Is this a follow up for
http://www.spinics.net/lists/linux-mm/msg39252.html? It would be better
to follow the thread in that case.

> 1.     How to allocate/increase the number of object on "size-65536"?

Object count is increased automatically and transparently for the cache
users. Why would you want to control its size from the outside?

> 2.     Where is the new allocated memory from? (from buddy?)

page allocator when it cannot find any room in the internally available
space. Have a look at [1] if you want to learn more about the slab
allocator (the code has changed since then but the princibles are still
valid).

[1] http://kernel.org/doc/gorman/html/understand/understand011.html

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
