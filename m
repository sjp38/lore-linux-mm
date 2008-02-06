Date: Wed, 6 Feb 2008 15:30:53 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 2/2] Explicitly retry hugepage allocations
In-Reply-To: <20080206231243.GG3477@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0802061529480.22648@schroedinger.engr.sgi.com>
References: <20080206230726.GF3477@us.ibm.com> <20080206231243.GG3477@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: melgor@ie.ibm.com, apw@shadowen.org, agl@us.ibm.com, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 6 Feb 2008, Nishanth Aravamudan wrote:

> Add __GFP_REPEAT to hugepage allocations. Do so to not necessitate
> userspace putting pressure on the VM by repeated echo's into
> /proc/sys/vm/nr_hugepages to grow the pool. With the previous patch to
> allow for large-order __GFP_REPEAT attempts to loop for a bit (as
> opposed to indefinitely), this increases the likelihood of getting
> hugepages when the system experiences (or recently experienced) load.
> 
> On a 2-way x86_64, this doubles the number of hugepages (from 10 to 20)
> obtained while compiling a kernel at the same time. On a 4-way ppc64,
> a similar scale increase is seen (from 3 to 5 hugepages). Finally, on a
> 2-way x86, this leads to a 5-fold increase in the hugepages allocatable
> under load (90 to 554).

Hmmm... How about defaulting to __GFP_REPEAT by default for larger page 
allocations? There are other users of larger allocs that would also 
benefit from the same measure. I think it would be fine as long as we are 
sure to fail at some point.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
