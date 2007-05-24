Date: Wed, 23 May 2007 21:05:20 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/3] slob: rework freelist handling
In-Reply-To: <20070524040149.GB20252@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0705232103260.24495@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0705222204460.3135@schroedinger.engr.sgi.com>
 <20070523051152.GC29045@wotan.suse.de> <Pine.LNX.4.64.0705222212200.3232@schroedinger.engr.sgi.com>
 <20070523052206.GD29045@wotan.suse.de> <Pine.LNX.4.64.0705222224380.12076@schroedinger.engr.sgi.com>
 <20070523061702.GA9449@wotan.suse.de> <20070523074636.GA10070@wotan.suse.de>
 <Pine.LNX.4.64.0705231006370.19822@schroedinger.engr.sgi.com>
 <20070524032417.GC14349@wotan.suse.de> <Pine.LNX.4.64.0705232048120.24352@schroedinger.engr.sgi.com>
 <20070524040149.GB20252@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 24 May 2007, Nick Piggin wrote:

> > Well as far as I understand Matt it seems that you still need 2 bytes per 
> > alloc. That is still more than 0 that SLUB needs.
> 
> That's true, but I think the more relevant number is that SLUB needs
> 400K more memory to boot into /bin/bash.

I am bit amazed by that. Where is that memory going to? What page size 
does the system have?

If we have 4k pages there then this boils down to 100 pages.

Does booting with

slub_max_order=0

change things?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
