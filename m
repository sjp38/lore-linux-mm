Date: Tue, 22 May 2007 12:18:58 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/3] slob: rework freelist handling
In-Reply-To: <20070522145345.GN11115@waste.org>
Message-ID: <Pine.LNX.4.64.0705221216300.30149@schroedinger.engr.sgi.com>
References: <20070522073910.GD17051@wotan.suse.de> <20070522145345.GN11115@waste.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 22 May 2007, Matt Mackall wrote:

> On Tue, May 22, 2007 at 09:39:10AM +0200, Nick Piggin wrote:
> > Here are some patches I have been working on for SLOB, which makes
> > it significantly faster, and also using less dynamic memory... at
> > the cost of being slightly larger static footprint and more complex
> > code.
> > 
> > Matt was happy for the first 2 to go into -mm (and hasn't seen patch 3 yet).
> 
> These all look good, thanks Nick!
> 
> Acked-by: Matt Mackall <mpm@selenic.com>

New SLUB inspired life for SLOB. I hope someone else tests this?

Are there any numbers / tests that give a continued reason for the 
existence of SLOB? I.e. show some memory usage on a real system that is 
actually lower than SLAB/SLUB? Or are there any confirmed platforms where 
SLOB is needed?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
