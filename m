Date: Fri, 25 Aug 2006 17:55:17 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: ZVC: Support NR_SLAB_RECLAIM
Message-Id: <20060825175517.b41f129d.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0608251728240.11715@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0608251500560.11154@schroedinger.engr.sgi.com>
	<20060825165659.0d8c03d4.akpm@osdl.org>
	<Pine.LNX.4.64.0608251728240.11715@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: npiggin@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 25 Aug 2006 17:30:09 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Fri, 25 Aug 2006, Andrew Morton wrote:
> 
> > On Fri, 25 Aug 2006 15:16:19 -0700 (PDT)
> > Christoph Lameter <clameter@sgi.com> wrote:
> > 
> > > Remove the atomic counter for slab_reclaim_pages and replace
> > > with a ZVC counter. NR_SLAB will now only count the
> > > unreclaimable slab pages whereas NR_SLAB_RECLAIM will count
> > > the reclaimable slab pages.
> > 
> > That's misleading.  We should rename NR_SLAB to NR_SLAB_UNRECLAIMABLE.  And
> > NR_SLAB_RECLAIM should be NR_SLAB_RECLAIMABLE, no?
> 
> Thats a bit long but yes we could do that.
> 
> > >  	n += hugetlb_report_node_meminfo(nid, buf + n);
> > >  	return n;
> > 
> > That breaks anything which uses the Slab: field.  OK, so it's NUMA geeks
> > only.  But still..
> 
> Well we already changed lots of names when we introduced the ZVCs.

hm, OK, well one assumes not many apps are reading that file.

btw, are there any handy userspace reporting tools out there which can
aggregate the per-node meminfo files?

> > We can add new fields though, so let's just have Slab:, SlabUnrecl: (ug)
> > and SlabReclaim: (ug).
> 
> Allright new patches will follow soon.

I just noticed /proc/meminfo's

	"NFS Unstable: %8lu kB\n"

We shouldn't do that.  Chances are that space will trip up someone's crappy
parser.  I'll replace it with an underscore.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
