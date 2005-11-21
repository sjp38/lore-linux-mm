Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id jAL5rsSE030455
	for <linux-mm@kvack.org>; Mon, 21 Nov 2005 00:53:54 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jAL5rsPt111434
	for <linux-mm@kvack.org>; Mon, 21 Nov 2005 00:53:54 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id jAL5rsLF018138
	for <linux-mm@kvack.org>; Mon, 21 Nov 2005 00:53:54 -0500
Message-ID: <438160F0.4010903@us.ibm.com>
Date: Sun, 20 Nov 2005 21:53:52 -0800
From: Matthew Dobson <colpatch@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/8] Critical Page Pool
References: <5511.1132472758@ocs3.ocs.com.au>
In-Reply-To: <5511.1132472758@ocs3.ocs.com.au>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Keith Owens <kaos@sgi.com>
Cc: linux-kernel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Keith Owens wrote:
> On Fri, 18 Nov 2005 11:32:57 -0800, 
> Matthew Dobson <colpatch@us.ibm.com> wrote:
> 
>>We have a clustering product that needs to be able to guarantee that the
>>networking system won't stop functioning in the case of OOM/low memory
>>condition.  The current mempool system is inadequate because to keep the
>>whole networking stack functioning, we need more than 1 or 2 slab caches to
>>be guaranteed.  We need to guarantee that any request made with a specific
>>flag will succeed, assuming of course that you've made your "critical page
>>pool" big enough.
>>
>>The following patch series implements such a critical page pool.  It
>>creates 2 userspace triggers:
>>
>>/proc/sys/vm/critical_pages: write the number of pages you want to reserve
>>for the critical pool into this file
>>
>>/proc/sys/vm/in_emergency: write a non-zero value to tell the kernel that
>>the system is in an emergency state and authorize the kernel to dip into
>>the critical pool to satisfy critical allocations.
> 
> 
> FWIW, the Kernel Debugger (KDB) has similar problems where the system
> is dying because of lack of memory but KDB must call some functions
> that use kmalloc.  A related problem is that sometimes KDB is invoked
> from a non maskable interrupt, so I could not even trust the state of
> the spinlocks and the chains in the slab code.
> 
> I worked around the problem by adding a last ditch allocator.  Extract
> from the kdb patch.

Ahh... very interesting.  And dissapointingly much smaller than mine. :(

Thanks for the patch and the feedback!

-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
