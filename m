Message-ID: <41BFEAA5.1090109@cosmosbay.com>
Date: Wed, 15 Dec 2004 08:41:25 +0100
From: Eric Dumazet <dada1@cosmosbay.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] NUMA boot hash allocation interleaving
References: <Pine.SGI.4.61.0412141140030.22462@kzerza.americas.sgi.com> <9250000.1103050790@flay> <20041214191348.GA27225@wotan.suse.de> <19030000.1103054924@flay> <Pine.SGI.4.61.0412141720420.22462@kzerza.americas.sgi.com> <20041215040854.GC27225@wotan.suse.de>
In-Reply-To: <20041215040854.GC27225@wotan.suse.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Brent Casavant <bcasavan@sgi.com>, "Martin J. Bligh" <mbligh@aracnet.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:

> 
> I actually considered implementing it for x86-64 some time ago
> for the modules, but then I never bothered. On AMD systems
> I actually prefer to use small pages here. The reason is that
> Opteron has a separated large and small pages TLB and the small
> pages TLB is much bigger. When someone else uses huge TLB 
> pages too (user space or kernel direct mapping) then it's actually
> a good idea to use small pages.

Interesting...

I actually use dual Opterons systems, with very large route cache hashes 
and tcp hashes. (rhash_entries=524288 thash_entries=524288), and a 
Hugetlb aware user space programs.

x86info tells me (maybe wrongly)

Family: 15 Model: 5 Stepping: 8
CPU Model : Opteron
Instruction TLB: Fully associative. 32 entries.
Data TLB: Fully associative. 32 entries.

and /proc/cpuinfo tells me :
model name      : AMD Opteron(tm) Processor 248
TLB size        : 1088 4K pages


My questions are :

1) Are the route cache and tcp hashes use big pages (2MB) on 2.6.5/2.6.9 
x86_64 kernels.
2) What are the exact number of data TLB entries (for small pages and 
huge ones) for opterons ?
3) All networks interrupts are handled by CPU0. Should we really use 
NUMA interleaved memory for hashes in this case ?

Thank you
Eric Dumazet
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
