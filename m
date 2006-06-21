Date: Wed, 21 Jun 2006 15:06:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Lhms-devel] [RFC] patch [1/1] x86_64 numa aware sparsemem
 add_memory	functinality
Message-Id: <20060621150653.e00c6d76.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1150868581.8518.28.camel@keithlap>
References: <1150868581.8518.28.camel@keithlap>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kmannth@us.ibm.com
Cc: lhms-devel@lists.sourceforge.net, prarit@redhat.com, linux-mm@kvack.org, darnok@us.ibm.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Tue, 20 Jun 2006 22:43:01 -0700
keith mannthey <kmannth@us.ibm.com> wrote:

> Hello all,
>   This patch is an attempt to add a numa ware add_memory functionality
> to x86_64 using CONFIG_SPARSEMEM.  The add memory function today just
> grabs the pgdat from node 0 and adds the memory there.  On a numa system
> this is functional but not optimal/correct. 
> 

At first, sorry for confusing.
reserve_hotadd()/memory-hot-add with preallocated mem_map things are 
maintained by x86_64 and Andi Kleen (maybe).
So we (lhms people) are not familiar with this.

And yes, mem_map should be allocated from local node.
I'm now preparing "dynamic local mem_map allocation" for lhms's memory hotplug,
which doesn't depend on SRAT.

Regards,
-Kame


>   The SRAT can expose future memory locality.  This information is
> already tracked by the nodes_add data structure (it keeps the
> memory/node locality information) from the SRAT code.  The code in
> srat.c is built around RESERVE_HOTADD.  This patch is a little subtle in
> the way it uses the existing code for use with sparsemem.  Perhaps
> acpi_numa_memory_affinity_init needs a larger refactor to fit both
> RESERVE_HOTADD and sparsemem.  
> 
>   This patch still hotadd_percent as a flag to the whole srat parsing
> code to disable and contain broken bios.  It's functionality is retained
> and an on off switch to sparsemem hot-add.  Without changing the safety
> mechanisms build into the current SRAT code I have provided a path for
> the sparsemem hot-add path to get to the nodes_add data for use at
> runtime. 
> 
>   This is a 1st run at the patch, it works with 2.6.17
> 
> Signed-off-by:  Keith Mannthey <kmannth@us.ibm.com>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
