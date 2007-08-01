From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 01/14] NUMA: Generic management of nodemasks for various purposes
Date: Wed, 1 Aug 2007 11:19:33 +0200
References: <20070727194316.18614.36380.sendpatchset@localhost> <Pine.LNX.4.64.0707312006550.22443@schroedinger.engr.sgi.com> <20070731203203.2691ca59.akpm@linux-foundation.org>
In-Reply-To: <20070731203203.2691ca59.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="ansi_x3.4-1968"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200708011119.33242.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, Mel Gorman <mel@skynet.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wednesday 01 August 2007 05:32:03 Andrew Morton wrote:
> On Tue, 31 Jul 2007 20:14:08 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:
> 
> > On Tue, 31 Jul 2007, Andrew Morton wrote:
> > 
> > > ooookay...   I don't think I want to be the first person who gets
> > > to do that, so I shall duck them for -mm2.
> > > 
> > > I think there were updates pending anyway.   I saw several under-replied-to
> > > patches from Lee but it wasn't clear it they were relevant to these changes
> > > or what.
> > 
> > I have not seen those. We also have the issue with slab allocations 
> > failing on NUMAQ with its HIGHMEM zones. 
> > 
> > Andi wants to drop support for NUMAQ again. Is that possible? NUMA only on 
> > 64 bit?
> 
> umm, that would need wide circulation.  I have a feeling that some
> implementations of some of the more obscure 32-bit architectures can (or
> will) have numa characteristics.  Looks like mips might already.

The problem here is really highmem and NUMA. If they only have lowmem
i guess it would be reasonably easy to support.

> And doesn't i386 summit do numa?

Yes, it does. But I don't think many are run in NUMA mode.


-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
