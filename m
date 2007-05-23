Date: Tue, 22 May 2007 22:28:54 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/3] slob: rework freelist handling
In-Reply-To: <20070523052206.GD29045@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0705222224380.12076@schroedinger.engr.sgi.com>
References: <20070522145345.GN11115@waste.org>
 <Pine.LNX.4.64.0705221216300.30149@schroedinger.engr.sgi.com>
 <20070523030637.GC9255@wotan.suse.de> <Pine.LNX.4.64.0705222154280.28140@schroedinger.engr.sgi.com>
 <20070523045938.GA29045@wotan.suse.de> <Pine.LNX.4.64.0705222200420.32184@schroedinger.engr.sgi.com>
 <20070523050333.GB29045@wotan.suse.de> <Pine.LNX.4.64.0705222204460.3135@schroedinger.engr.sgi.com>
 <20070523051152.GC29045@wotan.suse.de> <Pine.LNX.4.64.0705222212200.3232@schroedinger.engr.sgi.com>
 <20070523052206.GD29045@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 23 May 2007, Nick Piggin wrote:

> > This is intended for distro kernels so that you will not have to rebuild 
> > the kernel for slab debugging if slab corruption occurs.
> 
> OIC, neat. Anyway, the code size issue is still there, so I will
> test with the fix instead.

A code size issue? You mean SLUB is code wise larger than SLOB?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
