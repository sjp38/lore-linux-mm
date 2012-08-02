Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 65C926B005A
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 09:54:26 -0400 (EDT)
Date: Thu, 2 Aug 2012 08:54:23 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [question] how to increase the number of object on cache?
In-Reply-To: <5F2C6DA655B36C43B21C7FB179CEC9F4E3F157BDEE@HKMAIL02.nvidia.com>
Message-ID: <alpine.DEB.2.00.1208020852010.23049@router.home>
References: <5F2C6DA655B36C43B21C7FB179CEC9F4E3F157BDEE@HKMAIL02.nvidia.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shawn Joo <sjoo@nvidia.com>
Cc: "penberg@kernel.org" <penberg@kernel.org>, "mpm@selenic.com" <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.cz>

On Thu, 2 Aug 2012, Shawn Joo wrote:

> 1.     How to allocate/increase the number of object on "size-65536"?

I would suggest to use the page allocator directly for large allocations
like this. The slab allocators specialize in cutting 4k pages up in
smaller units and serving those units effectively.

> 2.     Where is the new allocated memory from? (from buddy?)

Ultimately yes but the slab allocators may have their own caching layer on
top given the slow as molasses page allocator. The caching effect is
excellent for small objects but not for large objects such as yours.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
