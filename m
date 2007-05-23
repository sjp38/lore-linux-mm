Date: Tue, 22 May 2007 23:28:18 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/3] slob: rework freelist handling
In-Reply-To: <20070523061702.GA9449@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0705222326260.16694@schroedinger.engr.sgi.com>
References: <20070523030637.GC9255@wotan.suse.de>
 <Pine.LNX.4.64.0705222154280.28140@schroedinger.engr.sgi.com>
 <20070523045938.GA29045@wotan.suse.de> <Pine.LNX.4.64.0705222200420.32184@schroedinger.engr.sgi.com>
 <20070523050333.GB29045@wotan.suse.de> <Pine.LNX.4.64.0705222204460.3135@schroedinger.engr.sgi.com>
 <20070523051152.GC29045@wotan.suse.de> <Pine.LNX.4.64.0705222212200.3232@schroedinger.engr.sgi.com>
 <20070523052206.GD29045@wotan.suse.de> <Pine.LNX.4.64.0705222224380.12076@schroedinger.engr.sgi.com>
 <20070523061702.GA9449@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 23 May 2007, Nick Piggin wrote:

> If you want to do a memory consumption shootout with SLOB, you need
> all the help you can get ;)

No way. And first you'd have to make SLOB functional. Among other 
things it does not support slab reclaim.

> OK, so with a 64-bit UP ppc kernel, compiled for size, and without full
> size data structures, booting with mem=16M init=/bin/bash.
> 
> 2.6.22-rc1-mm1 + your fix + my slob patches.
> 
> After booting and mounting /proc, SLOB has 1140K free, SLUB has 748K
> free.

Hmm.... Can I see the .config please?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
