Message-ID: <3CABF05C.4EA66796@scs.ch>
Date: Thu, 04 Apr 2002 08:19:08 +0200
From: Martin Maletinsky <maletinsky@scs.ch>
MIME-Version: 1.0
Subject: Re: Slab allocator - questions
References: <3CAAC471.ED65E4C9@scs.ch> <20020403143227.A6301@redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@redhat.com>
Cc: kernelnewbies@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

> ...
> > 2) Why are there general caches up to a size of 128K byte? Since a slab
> > consists of physically contiguous pages, one might call right into the
> > buddy system to get chunks of memory that are a multiple of a page size.
> > What is the benefit of allocating memory chunks that are a multiple of
> > a page size by using kmalloc()/kmem_cache_alloc() rather than
> > get_free_pages?
>
> Memory fragmentation.  By grouping objects of the same type and similar
> lifetimes, slab helps prevent the pinning of many individual pages across
> the system.  Since slab allocations cannot be relocated, this helps when
> other allocations need to obtain non-0 order pages.

Thank you for your reply. Could you detail how memory fragmentation is reduced? I understand the assumption that objects of the same type (and therefore same size) tend to
have similar lifetimes. However the general caches for objects that are a multiple of a page size contain one object per cache (see /proc/slabinfo). Each time such an
object is allocated by kmalloc(), the slab allocator will therefore use a new slab (which is allocated by calling into the buddy system). So what is the difference with
respect to memory fragmentation compared to calling straight the buddy system by using get_free_pages()?

regards
Martin
--
Supercomputing System AG          email: maletinsky@scs.ch
Martin Maletinsky                 phone: +41 (0)1 445 16 05
Technoparkstrasse 1               fax:   +41 (0)1 445 16 10
CH-8005 Zurich


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
