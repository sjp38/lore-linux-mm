Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 2E5F96B006C
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 12:39:36 -0500 (EST)
Date: Wed, 14 Nov 2012 17:39:28 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [RFC PATCH 0/3] introduce static_vm for ARM-specific static
	mapped area
Message-ID: <20121114173928.GK3290@n2100.arm.linux.org.uk>
References: <1352912154-16210-1-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1352912154-16210-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org

On Thu, Nov 15, 2012 at 01:55:51AM +0900, Joonsoo Kim wrote:
> In current implementation, we used ARM-specific flag, that is,
> VM_ARM_STATIC_MAPPING, for distinguishing ARM specific static mapped area.
> The purpose of static mapped area is to re-use static mapped area when
> entire physical address range of the ioremap request can be covered
> by this area.
> 
> This implementation causes needless overhead for some cases.

In what cases?

> We unnecessarily iterate vmlist for finding matched area even if there
> is no static mapped area. And if there are some static mapped areas,
> iterating whole vmlist is not preferable.

Why not?  Please put some explanation into your message rather than
just statements making unexplained assertions.

> Another reason for doing this work is for removing architecture dependency
> on vmalloc layer. I think that vmlist and vmlist_lock is internal data
> structure for vmalloc layer. Some codes for debugging and stat inevitably
> use vmlist and vmlist_lock. But it is preferable that they are used outside
> of vmalloc.c as least as possible.

The vmalloc layer is also made available for ioremap use, and it is
intended that architectures hook into this for ioremap support.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
