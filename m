Date: Thu, 26 Apr 2007 08:46:35 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] change global zonelist order on NUMA v2
In-Reply-To: <200704261147.44413.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0704260845160.1382@schroedinger.engr.sgi.com>
References: <20070426183417.058f6f9e.kamezawa.hiroyu@jp.fujitsu.com>
 <200704261147.44413.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, AKPM <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 26 Apr 2007, Andi Kleen wrote:

> On Thursday 26 April 2007 11:34:17 KAMEZAWA Hiroyuki wrote:
> > 
> > Changelog from V1 -> V2
> > - sysctl name is changed to be relaxed_zone_order
> > - NORMAL->NORMAL->....->DMA->DMA->DMA order (new ordering) is now default.
> >   NORMAL->DMA->NORMAL->DMA order (old ordering) is optional.
> > - addes boot opttion to set relaxed_zone_order. ia64 is supported now.
> > - Added documentation
> > 
> > patch is against 2.6.21-rc7-mm2. tested on ia64 NUMA box. works well.
> 
> IMHO the change should be default (without any options) unless someone
> can come up with a good reason why not. On x86-64 it should be definitely
> default.

It is not a good idea if node 0 has both DMA and NORMAL memory and normal 
memory is a small fraction of node memory. In that case lots of 
allocations get redirected to node 1.
 
> If there is a good reason on some architecture or machine a user option is also not a 
> good idea, but instead it should be set automatically by that architecture or machine
> on boot.

Right. That was my thinking.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
