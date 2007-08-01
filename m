Date: Tue, 31 Jul 2007 20:32:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 01/14] NUMA: Generic management of nodemasks for various
 purposes
Message-Id: <20070731203203.2691ca59.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0707312006550.22443@schroedinger.engr.sgi.com>
References: <20070727194316.18614.36380.sendpatchset@localhost>
	<20070727194322.18614.68855.sendpatchset@localhost>
	<20070731192241.380e93a0.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0707311946530.6158@schroedinger.engr.sgi.com>
	<20070731200522.c19b3b95.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0707312006550.22443@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, ak@suse.de, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, Mel Gorman <mel@skynet.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 31 Jul 2007 20:14:08 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:

> On Tue, 31 Jul 2007, Andrew Morton wrote:
> 
> > ooookay...   I don't think I want to be the first person who gets
> > to do that, so I shall duck them for -mm2.
> > 
> > I think there were updates pending anyway.   I saw several under-replied-to
> > patches from Lee but it wasn't clear it they were relevant to these changes
> > or what.
> 
> I have not seen those. We also have the issue with slab allocations 
> failing on NUMAQ with its HIGHMEM zones. 
> 
> Andi wants to drop support for NUMAQ again. Is that possible? NUMA only on 
> 64 bit?

umm, that would need wide circulation.  I have a feeling that some
implementations of some of the more obscure 32-bit architectures can (or
will) have numa characteristics.  Looks like mips might already.

And doesn't i386 summit do numa?

We could do it, but it would take some chin-scratching.  It'd be good if we
could pull it off.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
