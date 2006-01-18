From: Andi Kleen <ak@suse.de>
Subject: Re: Question:  new bind_zonelist uses only one zone type
Date: Wed, 18 Jan 2006 04:49:22 +0100
References: <43CCAEEF.5000403@jp.fujitsu.com> <200601180400.41448.ak@suse.de> <20060118034003.GA1300@sgi.com>
In-Reply-To: <20060118034003.GA1300@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200601180449.23269.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <clameter@sgi.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wednesday 18 January 2006 04:40, Jack Steiner wrote:
> On Wed, Jan 18, 2006 at 04:00:41AM +0100, Andi Kleen wrote:
> > On Wednesday 18 January 2006 00:47, KAMEZAWA Hiroyuki wrote:
> > > Andi Kleen wrote:
> > > > It was originally intended - back then either IA64 NUMA systems didn't
> > > > have a ZONE_DMA and on x86-64 it was only 16MB and for i386 NUMA
> > > > it was considered acceptable - and it made the  code simpler and policies
> > > > use less memory. But is now considered a bug because of the introduction
> > > > of ZONE_DMA32 on x86-64 and I gather from your report your platform
> > > > has NUMA and a 4GB ZONE_DMA too?
> > >
> > > on ia64, 0-4G area is ZONE_DMA.
> > 
> > On IA64/SN2 ZONE_DMA is empty and at least in the part SGI was the only
> > IA64 vendor actively interested in NUMA policy.
> > 
> 
> On the SN systems, ALL memory is in the DMA zone. The other zones are empty.

Ah sorry Jack got that wrong. Thanks for the correction. For the 
NUMA policy makes no difference though because only the highest zone
with pages populated counts.
 
> I think this is SN-specific - other IA64 platforms may be different & have memory
> in multiple zones. 

Yes, it is.

-Andi 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
