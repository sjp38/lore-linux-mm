Date: Thu, 24 May 2007 05:24:17 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 1/3] slob: rework freelist handling
Message-ID: <20070524032417.GC14349@wotan.suse.de>
References: <Pine.LNX.4.64.0705222200420.32184@schroedinger.engr.sgi.com> <20070523050333.GB29045@wotan.suse.de> <Pine.LNX.4.64.0705222204460.3135@schroedinger.engr.sgi.com> <20070523051152.GC29045@wotan.suse.de> <Pine.LNX.4.64.0705222212200.3232@schroedinger.engr.sgi.com> <20070523052206.GD29045@wotan.suse.de> <Pine.LNX.4.64.0705222224380.12076@schroedinger.engr.sgi.com> <20070523061702.GA9449@wotan.suse.de> <20070523074636.GA10070@wotan.suse.de> <Pine.LNX.4.64.0705231006370.19822@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705231006370.19822@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 23, 2007 at 10:07:33AM -0700, Christoph Lameter wrote:
> On Wed, 23 May 2007, Nick Piggin wrote:
> 
> > Oh, and just out of interest, SLOB before my patches winds up with
> > 1068K free, so it is good to know the patches were able to save a bit
> > on this setup.
> 
> Ahhh.. Its you who did the evil deed. By copying SLUB ideas SLOB became 
> better than SLUB. Wicked.... Lets see how far down we can get SLUB.

Not to be petty, but actually I didn't copy anything from SLUB and still
haven't looked at the code beyond changing the bit spinlock to use a
non-atomic store with my new bitops patches.

The reason SLOB is so space efficient really comes from Matt's no
compromises design. The thrust of my patches were after seeing how slow
it was on my 4GB system while testing the RCU implementation. They
were primarily intended to speed up the thing, but retain all the same
basic allocation algorithms -- a quirk of my implementation allowed
smaller freelist indexes which was a bonus, but as Matt said, slob was
still more efficient before the change.

What SLUB idea did you think I copied anyway?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
