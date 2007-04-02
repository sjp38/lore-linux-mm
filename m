Message-ID: <4611269C.2000709@google.com>
Date: Mon, 02 Apr 2007 08:51:56 -0700
From: "Martin J. Bligh" <mbligh@google.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] x86_64: Switch to SPARSE_VIRTUAL
References: <20070401071024.23757.4113.sendpatchset@schroedinger.engr.sgi.com> <200704011246.52238.ak@suse.de> <Pine.LNX.4.64.0704020832320.30394@schroedinger.engr.sgi.com> <200704021744.39880.ak@suse.de>
In-Reply-To: <200704021744.39880.ak@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andy Whitcroft <apw@shadowen.org>apw, please
List-ID: <linux-mm.kvack.org>

him on this stuff ?

Andi Kleen wrote:
> On Monday 02 April 2007 17:37, Christoph Lameter wrote:
>> On Sun, 1 Apr 2007, Andi Kleen wrote:
>>
>>> Hmm, this means there is at least 2MB worth of struct page on every node?
>>> Or do you have overlaps with other memory (I think you have)
>>> In that case you have to handle the overlap in change_page_attr()
>> Correct. 2MB worth of struct page is 128 mb of memory. Are there nodes 
>> with smaller amounts of memory? 
> 
> Yes the discontigmem minimum is 64MB and there are some setups
> (mostly with numa emulation) where you end up with nodes that small.

We're actually using numa emulation to do real (container) things with.
However, 128MB is still pretty small for that ... and worst case, we
just waste 1MB for a 64MB node, right? Which isn't beautiful, but
doesn't seem like the end of the world for an obscure corner case.

>>> Do you have any benchmarks numbers to prove it? There seem to be a few
>>> benchmarks where the discontig virt_to_page is a problem
>>> (although I know ways to make it more efficient), and sparsemem
>>> is normally slower. Still some numbers would be good.
>> You want a benchmark to prove that the removal of memory references and 
>> code improves performance?
> 
> You're just moving them into MMU, not really removing it.  And need more TLB entries.
> It might be faster or it might not. There are some unexpected issues, like most x86-64 
> CPUs have a quite small number of large TLBs so you can get thrashing etc.
> 
> So numbers with TLB intensive workloads would be good. 

There's also the possibility it just doesn't make enough difference
to affect a real benchmark ...

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
