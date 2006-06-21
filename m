Date: Wed, 21 Jun 2006 15:31:16 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [Lhms-devel] [RFC] patch [1/1] x86_64 numa aware sparsemem add_memory functinality
In-Reply-To: <20060621150653.e00c6d76.kamezawa.hiroyu@jp.fujitsu.com>
References: <1150868581.8518.28.camel@keithlap> <20060621150653.e00c6d76.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20060621151721.8B41.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kmannth@us.ibm.com
Cc: prarit@redhat.com, linux-mm@kvack.org, ak@suse.de, darnok@us.ibm.com, lhms-devel@lists.sourceforge.net, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> On Tue, 20 Jun 2006 22:43:01 -0700
> keith mannthey <kmannth@us.ibm.com> wrote:
> 
> > Hello all,
> >   This patch is an attempt to add a numa ware add_memory functionality
> > to x86_64 using CONFIG_SPARSEMEM.  The add memory function today just
> > grabs the pgdat from node 0 and adds the memory there.  On a numa system
> > this is functional but not optimal/correct. 
> > 
> 
> At first, sorry for confusing.
> reserve_hotadd()/memory-hot-add with preallocated mem_map things are 
> maintained by x86_64 and Andi Kleen (maybe).
> So we (lhms people) are not familiar with this.
>
> And yes, mem_map should be allocated from local node.
> I'm now preparing "dynamic local mem_map allocation" for lhms's memory hotplug,
> which doesn't depend on SRAT.

I wrote patches for NUMA aware memory hotplug with sparsemem.
It is already included in current -mm.
He means he would like to make the patch for -mm. Could you check it?
But, I've not try it with RESERVE_HOT_ADD. I just try it with sparsemem.
Sorry. :-(

In my patch, if new memory is in new node, new node id is decided by PXM
in dsdt. So, it must work even if srat does not define hot-add area.

Thanks.

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
