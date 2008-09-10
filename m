From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [Approach #2] [RFC][PATCH] Remove cgroup member from struct page
Date: Thu, 11 Sep 2008 08:38:20 +1000
References: <48C66AF8.5070505@linux.vnet.ibm.com> <20080910012048.GA32752@balbir.in.ibm.com> <1221085260.6781.69.camel@nimitz>
In-Reply-To: <1221085260.6781.69.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200809110838.20770.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: balbir@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, hugh@veritas.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursday 11 September 2008 08:21, Dave Hansen wrote:
> On Tue, 2008-09-09 at 18:20 -0700, Balbir Singh wrote:
> > +       start = pgdat->node_start_pfn;
> > +       end = pgdat->node_start_pfn + pgdat->node_spanned_pages;
> > +       size = (end - start) * sizeof(struct page_cgroup);
> > +       printk("Allocating %lu bytes for node %d\n", size, n);
> > +       pcg_map[n] = alloc_bootmem_node(pgdat, size);
> > +       /*
> > +        * We can do smoother recovery
> > +        */
> > +       BUG_ON(!pcg_map[n]);
> > +       return 0;
> >  }
>
> This will really suck for sparse memory machines.  Imagine a machine
> with 1GB of memory at 0x0 and another 1GB of memory at 1TB up in the
> address space.
>
> You also need to consider how it works with memory hotplug and how
> you're going to grow it at runtime.

I think it should try to hook into the physical memory model
code. I thought it was going to do that but didn't look at the
details...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
