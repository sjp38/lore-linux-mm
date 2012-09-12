Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 5A3FA6B00F9
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 16:39:25 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so3226062pbb.14
        for <linux-mm@kvack.org>; Wed, 12 Sep 2012 13:39:24 -0700 (PDT)
Date: Wed, 12 Sep 2012 13:39:20 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm: bootmem: use phys_addr_t for physical addresses
Message-ID: <20120912203920.GU7677@google.com>
References: <1347466008-7231-1-git-send-email-cyril@ti.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1347466008-7231-1-git-send-email-cyril@ti.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyril Chemparathy <cyril@ti.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, davem@davemloft.net, eric.dumazet@gmail.com, hannes@cmpxchg.org, shangw@linux.vnet.ibm.com, vitalya@ti.com

Hello,

On Wed, Sep 12, 2012 at 12:06:48PM -0400, Cyril Chemparathy wrote:
>  static void * __init alloc_bootmem_core(unsigned long size,
>  					unsigned long align,
> -					unsigned long goal,
> -					unsigned long limit)
> +					phys_addr_t goal,
> +					phys_addr_t limit)

So, a function which takes phys_addr_t for goal and limit but returns
void * doesn't make much sense unless the function creates directly
addressable mapping somewhere.

The right thing to do would be converting to nobootmem (ie. memblock)
and use the memblock interface.  Have no idea at all whether that
would be a realistic short-term solution for arm.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
