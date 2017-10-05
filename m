From: Christopher Lameter <cl@linux.com>
Subject: Re: [RFC] mmap(MAP_CONTIG)
Date: Thu, 5 Oct 2017 09:30:22 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1710050928040.2543@nuc-kabylake>
References: <21f1ec96-2822-1189-1c95-79a2bb491571@oracle.com> <3c28baa4-f8f5-a86e-4830-bf3c7c74ed4f@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3c28baa4-f8f5-a86e-4830-bf3c7c74ed4f@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Guy Shattah <sguy@mellanox.com>
List-Id: linux-mm.kvack.org

On Thu, 5 Oct 2017, Vlastimil Babka wrote:

> On 10/04/2017 01:56 AM, Mike Kravetz wrote:
> > At Plumbers this year, Guy Shattah and Christoph Lameter gave a presentation
> > titled 'User space contiguous memory allocation for DMA' [1].  The slides
> Hm I didn't find slides on that link, are they available?

I just added Guy's slides to the entry.

> As Michal N. noted, the drivers might have different requirements. Is
> contiguity (without extra requirements) so common that it would benefit
> from a userspace API change?

Yes.

> Also how are the driver-specific allocations done today? mmap() on the
> driver's device? Maybe we could provide some in-kernel API/library to
> make them less "ad-hoc". Conversion to MAP_ANONYMOUS would at first seem
> like an improvement in that userspace would be able to use a generic
> allocation API and all the generic treatment of anonymous pages (LRU
> aging, reclaim, migration etc), but the restrictions you listed below
> eliminate most of that?
> (It's likely that I just don't have enough info about how it works today
> so it's difficult to judge)

Contemporary devices typically can address all of memory. Moreover the
device used actually can trigger faults to page in 4k pages if they are
not present (ODP in RDMA layer). There is no need for driver specific
allocation in those drivers.
