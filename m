Date: Tue, 4 Mar 2008 12:01:29 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [BUG] 2.6.25-rc3-mm1 kernel panic while bootup on powerpc ()
In-Reply-To: <84144f020803041141x5bb55832r495d7fde92356e27@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0803041200140.18277@schroedinger.engr.sgi.com>
References: <20080304011928.e8c82c0c.akpm@linux-foundation.org>
 <47CD4AB3.3080409@linux.vnet.ibm.com>  <20080304103636.3e7b8fdd.akpm@linux-foundation.org>
  <47CDA081.7070503@cs.helsinki.fi> <20080304193532.GC9051@csn.ul.ie>
 <84144f020803041141x5bb55832r495d7fde92356e27@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>, linuxppc-dev@ozlabs.org, Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 4 Mar 2008, Pekka Enberg wrote:

> >  > >> [c000000009edf5f0] [c0000000000b56e4] .__alloc_pages_internal+0xf8/0x470
> >  > >> [c000000009edf6e0] [c0000000000e0458] .kmem_getpages+0x8c/0x194
> >  > >> [c000000009edf770] [c0000000000e1050] .fallback_alloc+0x194/0x254
> >  > >> [c000000009edf820] [c0000000000e14b0] .kmem_cache_alloc+0xd8/0x144

Ahh! This is SLAB. slub does not suffer this problem since new_slab() 
masks the bits correctly.

So we need to fix SLAB.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
