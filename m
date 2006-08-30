From: Andi Kleen <ak@suse.de>
Subject: Re: libnuma interleaving oddness
Date: Wed, 30 Aug 2006 09:19:13 +0200
References: <20060829231545.GY5195@us.ibm.com> <Pine.LNX.4.64.0608291655160.22397@schroedinger.engr.sgi.com> <20060830002110.GZ5195@us.ibm.com>
In-Reply-To: <20060830002110.GZ5195@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200608300919.13125.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, lnxninja@us.ibm.com, agl@us.ibm.com
List-ID: <linux-mm.kvack.org>

mous pages.
> 
> The order is (with necessary params filled in):
> 
> p = mmap( , newsize, RW, PRIVATE, unlinked_hugetlbfs_heap_fd, );
> 
> numa_interleave_memory(p, newsize);
> 
> mlock(p, newsize); /* causes all the hugepages to be faulted in */
> 
> munlock(p,newsize);
> 
> From what I gathered from the numa manpages, the interleave policy
> should take effect on the mlock, as that is "fault-time" in this
> context. We're forcing the fault, that is.

mlock shouldn't be needed at all here. the new hugetlbfs is supposed
to reserve at mmap time and numa_interleave_memory() sets a VMA 
policy which will should do the right thing no matter when the fault
occurs.

Hmm, maybe mlock() policy() is broken.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
