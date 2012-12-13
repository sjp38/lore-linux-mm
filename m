Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 69F4C6B002B
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 23:50:03 -0500 (EST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Wed, 12 Dec 2012 23:50:01 -0500
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id A5D6B6E803C
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 23:49:25 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qBD4nPII65732700
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 23:49:25 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qBD4nPE8007445
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 23:49:25 -0500
Message-ID: <50C95E4A.9010509@linux.vnet.ibm.com>
Date: Wed, 12 Dec 2012 20:49:14 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add node physical memory range to sysfs
References: <1354919696.2523.6.camel@buesod1.americas.hpqcorp.net> <20121207155125.d3117244.akpm@linux-foundation.org> <50C28720.3070205@linux.vnet.ibm.com> <1355361524.5255.9.camel@buesod1.americas.hpqcorp.net> <50C933E9.2040707@linux.vnet.ibm.com> <1355364222.9244.3.camel@buesod1.americas.hpqcorp.net>
In-Reply-To: <1355364222.9244.3.camel@buesod1.americas.hpqcorp.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr.bueso@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 12/12/2012 06:03 PM, Davidlohr Bueso wrote:
> On Wed, 2012-12-12 at 17:48 -0800, Dave Hansen wrote:
>> But if we went and did it per-DIMM (showing which physical addresses and
>> NUMA nodes a DIMM maps to), wouldn't that be redundant with this
>> proposed interface?
> 
> If DIMMs overlap between nodes, then we wouldn't have an exact range for
> a node in question. Having both approaches would complement each other.

How is that possible?  If NUMA nodes are defined by distances from CPUs
to memory, how could a DIMM have more than a single distance to any
given CPU?

>> How do you plan to use this in practice, btw?
> 
> It started because I needed to recognize the address of a node to remove
> it from the e820 mappings and have the system "ignore" the node's
> memory.

Actually, now that I think about it, can you check in the
/sys/devices/system/ directories for memory and nodes?  We have linkages
there for each memory section to every NUMA node, and you can also
derive the physical address from the phys_index in each section.  That
should allow you to work out physical addresses for a given node.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
