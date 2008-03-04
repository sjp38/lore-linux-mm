Message-ID: <47CDB498.6040003@cs.helsinki.fi>
Date: Tue, 04 Mar 2008 22:44:08 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [BUG] 2.6.25-rc3-mm1 kernel panic while bootup on powerpc ()
References: <20080304011928.e8c82c0c.akpm@linux-foundation.org>	<47CD4AB3.3080409@linux.vnet.ibm.com>	<20080304103636.3e7b8fdd.akpm@linux-foundation.org>	<47CDA081.7070503@cs.helsinki.fi>	<20080304193532.GC9051@csn.ul.ie>	<84144f020803041141x5bb55832r495d7fde92356e27@mail.gmail.com>	<Pine.LNX.4.64.0803041151360.18160@schroedinger.engr.sgi.com>	<Pine.LNX.4.64.0803042200410.8545@sbz-30.cs.Helsinki.FI>	<Pine.LNX.4.64.0803041205370.18277@schroedinger.engr.sgi.com> <20080304123459.364f879b.akpm@linux-foundation.org>
In-Reply-To: <20080304123459.364f879b.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, mel@csn.ul.ie, kamalesh@linux.vnet.ibm.com, linuxppc-dev@ozlabs.org, apw@shadowen.org, linux-mm@kvack.org, stable@kernel.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Tue, 4 Mar 2008 12:07:39 -0800 (PST)
> Christoph Lameter <clameter@sgi.com> wrote:
> 
>> I think this is the correct fix.
>>
>> The NUMA fallback logic should be passing local_flags to kmem_get_pages() 
>> and not simply the flags.
>>
>> Maybe a stable candidate since we are now simply 
>> passing on flags to the page allocator on the fallback path.
> 
> Do we know why this is only reported in 2.6.25-rc3-mm1?
> 
> Why does this need fixing in 2.6.24.x?

Looking at the code, it's triggerable in 2.6.24.3 at least. Why we don't 
have a report yet, probably because (1) the default allocator is SLUB 
which doesn't suffer from this and (2) you need a big honkin' NUMA box 
that causes fallback allocations to happen to trigger it.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
