Date: Thu, 4 Apr 2002 17:30:16 -0500
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: Slab allocator - questions
Message-ID: <20020404173016.C24914@redhat.com>
References: <3CAAC471.ED65E4C9@scs.ch> <20020403143227.A6301@redhat.com> <3CABF05C.4EA66796@scs.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3CABF05C.4EA66796@scs.ch>; from maletinsky@scs.ch on Thu, Apr 04, 2002 at 08:19:08AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Maletinsky <maletinsky@scs.ch>
Cc: kernelnewbies@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 04, 2002 at 08:19:08AM +0200, Martin Maletinsky wrote:
> Thank you for your reply. Could you detail how memory fragmentation is 
> reduced? I understand the assumption that objects of the same type (and 
> therefore same size) tend to have similar lifetimes. However the general 
> caches for objects that are a multiple of a page size contain one object 
> per cache (see /proc/slabinfo). Each time such an object is allocated by 
> kmalloc(), the slab allocator will therefore use a new slab (which is 
> allocated by calling into the buddy system). So what is the difference 
> with > respect to memory fragmentation compared to calling straight the 
> buddy system by using get_free_pages()?

You're making assumptions about the page size of the system.  True, on 
most platforms it will result in the same effect as directly hitting the 
page allocator, but that is not always the case.  Think of ia64 with 
large page sizes (64KB and 256KB are supported by the hardware iirc).  In 
that case the slab will have an effect.

That said, the main reason for having the large slabs is backwards 
compatibility with kmalloc.

		-ben
-- 
"A man with a bass just walked in,
 and he's putting it down
 on the floor."
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
