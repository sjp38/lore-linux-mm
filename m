Message-ID: <47A8C508.6010305@cs.helsinki.fi>
Date: Tue, 05 Feb 2008 22:20:24 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: SLUB: Support for statistics to help analyze allocator behavior
References: <Pine.LNX.4.64.0802042217460.6801@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0802050923220.14675@sbz-30.cs.Helsinki.FI> <Pine.LNX.4.64.0802051005010.11705@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0802051005010.11705@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Tue, 5 Feb 2008, Pekka J Enberg wrote:
> 
>> Hi Christoph,
>>
>> On Mon, 4 Feb 2008, Christoph Lameter wrote:
>>> The statistics provided here allow the monitoring of allocator behavior
>>> at the cost of some (minimal) loss of performance. Counters are placed in
>>> SLUB's per cpu data structure that is already written to by other code.
>> Looks good but I am wondering if we want to make the statistics per-CPU so 
>> that we can see the kmalloc/kfree ping-pong of, for example, hackbench 
> 
> We could do that.... Any idea how to display that kind of information 
> in a meaningful way. Parameter conventions for slabinfo?

We could just print out one total summary and one summary for each CPU 
(and maybe show % of total allocations/fees. That way you can 
immediately spot if some CPUs are doing more allocations/freeing than 
others.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
