Date: Mon, 27 Aug 2007 18:46:12 +0000
From: Mike Travis <travis@cthulhu.engr.sgi.com>
Subject: Re: [PATCH 0/6] x86: Reduce Memory Usage and Inter-Node message
 traffic (v2)
In-Reply-To: <20070825092434.GE16227@bingen.suse.de>
Message-ID: <Pine.SGI.4.56.0708271838210.4349416@kluge.engr.sgi.com>
References: <20070824222654.687510000@sgi.com> <20070825005017.GC1894@linux-os.sc.intel.com>
 <20070825092434.GE16227@bingen.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: "Siddha, Suresh B" <suresh.b.siddha@intel.com>, travis@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>


On Sat, 25 Aug 2007, Andi Kleen wrote:

> On Fri, Aug 24, 2007 at 05:50:18PM -0700, Siddha, Suresh B wrote:
> > On Fri, Aug 24, 2007 at 03:26:54PM -0700, travis@sgi.com wrote:
> > > Previous Intro:
> >
> > Thanks for doing this.
> >
> > > In x86_64 and i386 architectures most arrays that are sized
> > > using NR_CPUS lay in local memory on node 0.  Not only will most
> > > (99%?) of the systems not use all the slots in these arrays,
> > > particularly when NR_CPUS is increased to accommodate future
> > > very high cpu count systems, but a number of cache lines are
> > > passed unnecessarily on the system bus when these arrays are
> > > referenced by cpus on other nodes.
> >
> > Can we move cpuinfo_x86 also to per cpu area? Though critical run
>
> I worry how much impact that would be? boot_cpu_data is quite
> widely used.
>

I looked at this and it would be a big memory savings.  But I haven't
yet analyzed the various accesses to verify that we can cleanly move
the structure, and that we don't suffer a bunch of tlb misses because
accesses are primarily from node 0.

More info soon.

Thanks,
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
