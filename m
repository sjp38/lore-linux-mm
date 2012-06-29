Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 315646B005A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 23:19:49 -0400 (EDT)
Message-ID: <4FED1E4E.7000403@intel.com>
Date: Fri, 29 Jun 2012 11:17:34 +0800
From: Alex Shi <alex.shi@intel.com>
MIME-Version: 1.0
Subject: Re: [RFC] Common code 00/12] Sl[auo]b: Common functionality V2
References: <20120518161906.207356777@linux.com> <4FD55734.60104@intel.com>
In-Reply-To: <4FD55734.60104@intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>

On 06/11/2012 10:25 AM, Alex Shi wrote:

> On 05/19/2012 12:19 AM, Christoph Lameter wrote:
> 
>> V1->V2:
>> - Incorporate glommers feedback.
>> - Add 2 more patches dealing with common code in kmem_cache_destroy
> 
> 
> I tested the patchset on 3.4 kernel with hackbench process/thread:
> $hackbench 100 process/thread 2000
> 
> on Romely EP machine. 32 LCPUs, with 64GB memory
> hackbench process	slub	0%
> hackbench thread	slub	0%
> hackbench process	slab	-6.0%
> hackbench thread	slab	-0.5%
> 
> on NHM EP machine, 16 cpus, with 12GB memory
> hackbench process	slub	-1.0%
> hackbench thread	slub	-1.5%
> hackbench process	slab	+1.0%
> hackbench thread	slab	+1.0%
> hackbench process	slob	0%
> hackbench thread	slob	0%
> 
> on 4 sockets Quad-core Xeon, 16 cpus, with 16 GB memory
> hackbench process	slub	0%
> hackbench thread	slub	0%
> hackbench process	slab	-0.5%
> hackbench thread	slab	-0.5%
> hackbench process	slob	0%
> hackbench thread	slob	0%
> 
> 
> On netperf loopback, 2048 threads testing. In general, compare tcp/udp
> results, no clear performance change on above three machines.


Generally, I think the patchset is qualified for LKP. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
