Date: Sun, 16 Sep 2007 13:10:50 +0100
Subject: Re: [PATCH/RFC] Add node states sysfs class attributeS - V5
Message-ID: <20070916121050.GD1140@skynet.ie>
References: <20070827231214.99e3c33f.akpm@linux-foundation.org> <1188309928.5079.37.camel@localhost> <Pine.LNX.4.64.0708281458520.17559@schroedinger.engr.sgi.com> <29495f1d0708281513g406af15an8139df5fae20ad35@mail.gmail.com> <1188398621.5121.13.camel@localhost> <Pine.LNX.4.64.0708291039210.21184@schroedinger.engr.sgi.com> <1189518975.5036.3.camel@localhost> <20070914035058.89b13fa4.akpm@linux-foundation.org> <20070914144300.GE30407@skynet.ie> <20070914150044.GA8123@linux-sh.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20070914150044.GA8123@linux-sh.org>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mundt <lethal@linux-sh.org>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <clameter@sgi.com>, Nish Aravamudan <nish.aravamudan@gmail.com>, y-goto@jp.fujitsu.com, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Eric Whitney <eric.whitney@hp.com>, Andy Whitcroft <apw@shadowen.org>, Martin Bligh <mbligh@mbligh.org>
List-ID: <linux-mm.kvack.org>

On (15/09/07 00:00), Paul Mundt didst pronounce:
> On Fri, Sep 14, 2007 at 03:43:00PM +0100, Mel Gorman wrote:
> > On (14/09/07 03:50), Andrew Morton didst pronounce:
> > > So how do we get it tested with CONFIG_HIGHMEM=y?  Needs an i386
> > > numa machine, yes?  Perhaps Andy or Martin can remember to do this
> > > sometime, but they'll need a test plan ;)
> > 
> > As an aside, 32 Bit NUMA usually means we turn the NUMAQ into a whipping boy
> > and give the problem lip service. However, I'd be interested in hearing if
> > superh has dependencies on 32 bit NUMA working properly, including HIGHMEM
> > issues.
> > 
> > I've cc'd Paul Mundt. Paul, does superh use 32 bit NUMA? Is it used with
> > with HIGHMEM?
> > 
> We do use 32-bit NUMA, yes. Not with highmem at the moment, though.
> highmem support is something that will be coming soon, so the 32-bit NUMA
> + highmem assertion will be true on SH in the not-so-distant future.
> 
> This is something that quite a few CPUs and boards are depending on, and
> these are all using static sparsemem exclusively at present. It's also
> something that's tested with current git on a close to daily basis,
> albeit with page migration generally disabled, due to the small size of
> the non-system memory nodes.
> 

Ok, thanks Paul. It confirms that 32 bit NUMA is not something that will
disappear when the NUMAQs finally kick the bucket.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
