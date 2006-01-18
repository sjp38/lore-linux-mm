Date: Tue, 17 Jan 2006 21:40:03 -0600
From: Jack Steiner <steiner@sgi.com>
Subject: Re: Question:  new bind_zonelist uses only one zone type
Message-ID: <20060118034003.GA1300@sgi.com>
References: <43CCAEEF.5000403@jp.fujitsu.com> <200601171529.53811.ak@suse.de> <43CD822C.6020105@jp.fujitsu.com> <200601180400.41448.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200601180400.41448.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <clameter@sgi.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 18, 2006 at 04:00:41AM +0100, Andi Kleen wrote:
> On Wednesday 18 January 2006 00:47, KAMEZAWA Hiroyuki wrote:
> > Andi Kleen wrote:
> > > It was originally intended - back then either IA64 NUMA systems didn't
> > > have a ZONE_DMA and on x86-64 it was only 16MB and for i386 NUMA
> > > it was considered acceptable - and it made the  code simpler and policies
> > > use less memory. But is now considered a bug because of the introduction
> > > of ZONE_DMA32 on x86-64 and I gather from your report your platform
> > > has NUMA and a 4GB ZONE_DMA too?
> >
> > on ia64, 0-4G area is ZONE_DMA.
> 
> On IA64/SN2 ZONE_DMA is empty and at least in the part SGI was the only
> IA64 vendor actively interested in NUMA policy.
> 

On the SN systems, ALL memory is in the DMA zone. The other zones are empty.

I think this is SN-specific - other IA64 platforms may be different & have memory
in multiple zones. 

-- 
Jack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
