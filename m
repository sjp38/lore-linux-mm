Date: Tue, 10 Apr 2007 16:47:11 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: [SLUB 3/5] Validation of slabs (metadata and guard zones)
Message-ID: <20070410204711.GB1283@redhat.com>
References: <20070410191910.8011.76133.sendpatchset@schroedinger.engr.sgi.com> <20070410191921.8011.16929.sendpatchset@schroedinger.engr.sgi.com> <20070410133137.e366a16b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070410133137.e366a16b.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 10, 2007 at 01:31:37PM -0700, Andrew Morton wrote:
 
 > > an object have not been compromised.
 > > 
 > > A single slabcache can be checked by writing a 1 to the "validate" file.
 > > 
 > > i.e.
 > > 
 > > echo 1 >/sys/slab/kmalloc-128/validate
 > > 
 > > or use the slabinfo tool to check all slabs
 > > 
 > > slabinfo -v
 > > 
 > > Error messages will show up in the syslog.
 > 
 > Neato.

I had a patch (I think originally from Manfred Spraul) that I carried
in Fedora for a while which this patch reminded me of.
Instead of a /sys file however, it ran off a timer every few
minutes to check redzones of unfreed objects.  It picked up a few bugs,
but eventually, I got bored rediffing it, it broke, and it fell by
the wayside.  (It was against slab too, rather than one of its
decendants).

Whilst I nursed that along for a few months, I made a few not-so-agressive
pushes to get it mainlined, but there seemed to be no real interest.
(Yikes, something that'll show we have *more* bugs? Noooo!)

Would be nice to have equal functionality across the different allocators.

	Dave

-- 
http://www.codemonkey.org.uk

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
