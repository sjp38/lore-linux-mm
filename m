Date: Thu, 24 May 2007 06:49:32 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 1/3] slob: rework freelist handling
Message-ID: <20070524044932.GD12121@wotan.suse.de>
References: <20070523193547.GE11115@waste.org> <Pine.LNX.4.64.0705231256001.21541@schroedinger.engr.sgi.com> <20070524033925.GD14349@wotan.suse.de> <Pine.LNX.4.64.0705232052040.24352@schroedinger.engr.sgi.com> <20070524041339.GC20252@wotan.suse.de> <Pine.LNX.4.64.0705232115140.24618@schroedinger.engr.sgi.com> <20070524043144.GB12121@wotan.suse.de> <Pine.LNX.4.64.0705232133130.24738@schroedinger.engr.sgi.com> <20070524043928.GC12121@wotan.suse.de> <Pine.LNX.4.64.0705232143570.24864@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705232143570.24864@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 23, 2007 at 09:46:51PM -0700, Christoph Lameter wrote:
> Hmmm.. This confirms your findings:
> 
> 16m x86_64 boot with bin/bash
> 
> SLOB:
>              total       used       free     shared    buffers     cached
> Mem:         11660       9344       2316          0        256       3240
> -/+ buffers/cache:       5848       5812
> 
> 
> SLUB:
>              total       used       free     shared    buffers     cached
> Mem:         11652       9684       1968          0        256       3240
> -/+ buffers/cache:       6188       5464
> Swap:            0          0          0
> 
> So a little less than 400k wastage.

It would be interesting to see how a 32-bit system goes as well. I'll
try i386 when I get time.
 
> No changes to the kmalloc array.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
