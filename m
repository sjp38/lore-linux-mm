Date: Wed, 23 May 2007 13:02:53 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/3] slob: rework freelist handling
In-Reply-To: <20070523195824.GF11115@waste.org>
Message-ID: <Pine.LNX.4.64.0705231300070.21541@schroedinger.engr.sgi.com>
References: <20070523051152.GC29045@wotan.suse.de>
 <Pine.LNX.4.64.0705222212200.3232@schroedinger.engr.sgi.com>
 <20070523052206.GD29045@wotan.suse.de> <Pine.LNX.4.64.0705222224380.12076@schroedinger.engr.sgi.com>
 <20070523061702.GA9449@wotan.suse.de> <Pine.LNX.4.64.0705222326260.16694@schroedinger.engr.sgi.com>
 <20070523071200.GB9449@wotan.suse.de> <Pine.LNX.4.64.0705230956160.19822@schroedinger.engr.sgi.com>
 <20070523183224.GD11115@waste.org> <Pine.LNX.4.64.0705231208380.21222@schroedinger.engr.sgi.com>
 <20070523195824.GF11115@waste.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 23 May 2007, Matt Mackall wrote:

> Meanwhile this function is only called from swsusp.c.

NR_SLAB_UNRECLAIMABLE is also used in  __vm_enough_memory and 
in zone reclaim (well ok thats only NUMA).

Plus the SLAB sizes are not reported to user space. We see 0 in 
/proc/meminfo etc etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
