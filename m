Message-ID: <3CAAC471.ED65E4C9@scs.ch>
Date: Wed, 03 Apr 2002 10:59:29 +0200
From: Martin Maletinsky <maletinsky@scs.ch>
MIME-Version: 1.0
Subject: Slab allocator - questions
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kernelnewbies@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I am currently studying the Slab allocator, and therefor studied the paper of Jeff Bonwick and the respective section in 'Understanding the Linux Kernel' by Bovet&Cesati.
Still I have the following questions:

1) What is the benefit of storing object descriptors (kmem_bufctl_t) and slab descriptors (kmem_slab_t) in the slab (for small objects) within the slab? Alternatively the
in-slab memory
occupied by those descriptors could be used to store additional objects in that slab, i.e. I don't see
that this saves any memory; however having two alternate places to store object & slab descriptors
increases the complexity of the implementation.

2) Why are there general caches up to a size of 128K byte? Since a slab consists of physically contiguous pages, one might call right into the buddy system to get chunks of
memory that are a
multiple of a page size. What is the benefit of allocating memory chunks that are a multiple of a page size by using kmalloc()/kmem_cache_alloc() rather than
get_free_pages?
[I am familiar with Intel and Alpha only, are there maybe architectures that have page sizes > 128K - this might be an explanation for having slab caches for memory chunks
up to 128 K]

3) How does the slab cache allocator deal with high memory pages in 2.4.x (i.e. pages for which no
KSEG address exists)? The comment at the beginning of slab.c states, that a cache can support memory of type GFP_HIGHMEM, however in kmem_cache_free_one() the
virt_to_page() macro is applied to the pointer to an object from the slab - however this macro only works for KSEG (logical) addresses. Why does the implementation still
behave correctly, even if it uses high memory (for which no KSEG addresses exist)?

Please put me on cc: in your reply, since I am not in the mailing lists.

thanks in advance for any help,
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
