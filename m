Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 744D06B0119
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 20:34:07 -0400 (EDT)
Received: by dadi14 with SMTP id i14so1535646dad.14
        for <linux-mm@kvack.org>; Wed, 12 Sep 2012 17:34:06 -0700 (PDT)
Date: Wed, 12 Sep 2012 17:34:00 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm: bootmem: use phys_addr_t for physical addresses
Message-ID: <20120913003400.GA25889@localhost>
References: <1347466008-7231-1-git-send-email-cyril@ti.com>
 <20120912203920.GU7677@google.com>
 <505123FE.2090305@ti.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <505123FE.2090305@ti.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyril Chemparathy <cyril@ti.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, davem@davemloft.net, eric.dumazet@gmail.com, hannes@cmpxchg.org, shangw@linux.vnet.ibm.com, vitalya@ti.com

Hello,

On Wed, Sep 12, 2012 at 08:08:30PM -0400, Cyril Chemparathy wrote:
> >So, a function which takes phys_addr_t for goal and limit but returns
> >void * doesn't make much sense unless the function creates directly
> >addressable mapping somewhere.
> 
> On the 32-bit PAE platform in question, physical memory is located
> outside the 4GB range.  Therefore phys_to_virt takes a 64-bit
> physical address and returns a 32-bit kernel mapped lowmem pointer.

Yes but phys_to_virt() can return the vaddr only if the physical
address is already mapped in the kernel address space; otherwise, you
need one of the kmap*() calls which may not be online early in the
boot and consumes either the vmalloc area or fixmaps.  bootmem
interface can't handle unmapped memory.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
