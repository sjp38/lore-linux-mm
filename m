Date: Wed, 21 Jun 2006 15:37:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Lhms-devel] [RFC] patch [1/1] x86_64 numa aware sparsemem
 add_memory	functinality
Message-Id: <20060621153719.7d836e78.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1150871101.8518.57.camel@keithlap>
References: <1150868581.8518.28.camel@keithlap>
	<20060621150653.e00c6d76.kamezawa.hiroyu@jp.fujitsu.com>
	<1150871101.8518.57.camel@keithlap>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kmannth@us.ibm.com
Cc: prarit@redhat.com, linux-mm@kvack.org, ak@suse.de, darnok@us.ibm.com, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Tue, 20 Jun 2006 23:25:01 -0700
keith mannthey <kmannth@us.ibm.com> wrote:

> > And yes, mem_map should be allocated from local node.
> > I'm now preparing "dynamic local mem_map allocation" for lhms's memory hotplug,
> > which doesn't depend on SRAT.
> 
> How do you know which node to add the memory too without something like
> the SRAT that define memory locality of hot-add zones? SPARSEMEM doesn't
> depend on SRAT (it just needs to use to to know what zone to add to.)
> 
Now, acpi's _PXM method is supported by acpi-memory-hotadd. (See -mm.)
I'll use it. and current add_memory() -mm is this.
==
int arch_add_memory(int nid, u64 start, u64 size)
{
        struct pglist_data *pgdat = NODE_DATA(nid);
        struct zone *zone = pgdat->node_zones + MAX_NR_ZONES-2;
        unsigned long start_pfn = start >> PAGE_SHIFT;
        unsigned long nr_pages = size >> PAGE_SHIFT;
==
nid is passed by caller.


> This patch isn't about mem_map allocation rather what zone to add the
> memory to when doing SPASEMEM hot-add.  A numa aware mem_map allocation
> would belong in generic SPARSEMEM code. 
> 
I also need to do NUMA-aware 
- pgdat allocation , wait table allocation ..and so on...

I'll add memory allocater which allocates memory from newly-added-memory.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
