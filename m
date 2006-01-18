From: Andi Kleen <ak@suse.de>
Subject: Re: Question:  new bind_zonelist uses only one zone type
Date: Wed, 18 Jan 2006 04:00:41 +0100
References: <43CCAEEF.5000403@jp.fujitsu.com> <200601171529.53811.ak@suse.de> <43CD822C.6020105@jp.fujitsu.com>
In-Reply-To: <43CD822C.6020105@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200601180400.41448.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wednesday 18 January 2006 00:47, KAMEZAWA Hiroyuki wrote:
> Andi Kleen wrote:
> > It was originally intended - back then either IA64 NUMA systems didn't
> > have a ZONE_DMA and on x86-64 it was only 16MB and for i386 NUMA
> > it was considered acceptable - and it made the  code simpler and policies
> > use less memory. But is now considered a bug because of the introduction
> > of ZONE_DMA32 on x86-64 and I gather from your report your platform
> > has NUMA and a 4GB ZONE_DMA too?
>
> on ia64, 0-4G area is ZONE_DMA.

On IA64/SN2 ZONE_DMA is empty and at least in the part SGI was the only
IA64 vendor actively interested in NUMA policy.

I assume you have a NUMA platform too. Do your machines have a contiguous
memory map where there could be one or more nodes which only
have ZONE_DMA?

> > It is on my todo list to fix, but I haven't gotten around to it yet.
> >
> > Fixing it will unfortunately increase the footprint of the policy
> > structures, so likely it would only increase to two. If someone beats me
> > to a patch that would be ok too.
>
> I don't have real problem now. It just looks curious.

Well it's a bit nasty to not be able to policy 4GB of your memory. Maybe
if you have a few TB of it you won't care, but on smaller machines
it likely will make a difference.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
