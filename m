Date: Wed, 23 May 2007 20:49:30 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/3] slob: rework freelist handling
In-Reply-To: <20070524032417.GC14349@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0705232048120.24352@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0705222200420.32184@schroedinger.engr.sgi.com>
 <20070523050333.GB29045@wotan.suse.de> <Pine.LNX.4.64.0705222204460.3135@schroedinger.engr.sgi.com>
 <20070523051152.GC29045@wotan.suse.de> <Pine.LNX.4.64.0705222212200.3232@schroedinger.engr.sgi.com>
 <20070523052206.GD29045@wotan.suse.de> <Pine.LNX.4.64.0705222224380.12076@schroedinger.engr.sgi.com>
 <20070523061702.GA9449@wotan.suse.de> <20070523074636.GA10070@wotan.suse.de>
 <Pine.LNX.4.64.0705231006370.19822@schroedinger.engr.sgi.com>
 <20070524032417.GC14349@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 24 May 2007, Nick Piggin wrote:

> The reason SLOB is so space efficient really comes from Matt's no
> compromises design. The thrust of my patches were after seeing how slow
> it was on my 4GB system while testing the RCU implementation. They
> were primarily intended to speed up the thing, but retain all the same
> basic allocation algorithms -- a quirk of my implementation allowed
> smaller freelist indexes which was a bonus, but as Matt said, slob was
> still more efficient before the change.

Well as far as I understand Matt it seems that you still need 2 bytes per 
alloc. That is still more than 0 that SLUB needs.
 
> What SLUB idea did you think I copied anyway?

The use of the page struct.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
