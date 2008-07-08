Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Subject: Kmem_cache handling in linux-2.6.2x kernel
Date: Tue, 8 Jul 2008 13:15:26 +0800
Message-ID: <31E09F73562D7A4D82119D7F6C17298604696CEA@sinse303.ap.infineon.com>
From: <KokHow.Teh@infineon.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi list;
	I have a question about kmem_cache implemented in Linux-2.6.2x
kernel. I have an application that allocates and free 64KByte chunks of
memory (32-byte aligned) quite often. Therefore, I create a lookaside
cache for that purpose and use kmem_cache_alloc(), kmem_cache_free() to
allocate and free the caches. The application works very well in this
model. However, my concern here is if kmem_cache_free() does return the
cache to the system-wide pool so that it could be used by other
applications when need arises; when system is low in memory resources,
for instance. This is a question about the internal workings of the
memory management system of the Linux-2.6.2x kernel as to how efficient
it manages this lookasie caches. The concern is valid because if this
lookaside cache is not managed well, i.e, it is not returned to the
system-wide free memory pools to be used by other applications, this
will penalize the performace and throughput of the whole system due to
the dynamic behaviour of the utilization of system memory resources. For
example, other applications might be swapping in and out of the harddisk
and if the kmem_cache_free()'ed memory objects could be used by these
applications, it will help in this case to reduce the number of swaps
that happen, thereby freeing the CPU and/or DMA from doing the swapping
to do other critical tasks.

	On the other hand, if the caches are returned to the system-wide
free memory pool, what are the advantages of using kmem_cache_t compared
to the conventional kmalloc()/kfree()?

	Any insight and advice is appreciated.

Regards,
KH

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
