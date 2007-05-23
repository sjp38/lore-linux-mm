Date: Tue, 22 May 2007 22:01:33 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/3] slob: rework freelist handling
In-Reply-To: <20070523045938.GA29045@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0705222200420.32184@schroedinger.engr.sgi.com>
References: <20070522073910.GD17051@wotan.suse.de> <20070522145345.GN11115@waste.org>
 <Pine.LNX.4.64.0705221216300.30149@schroedinger.engr.sgi.com>
 <20070523030637.GC9255@wotan.suse.de> <Pine.LNX.4.64.0705222154280.28140@schroedinger.engr.sgi.com>
 <20070523045938.GA29045@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 23 May 2007, Nick Piggin wrote:

> No. With CONFIG_SLUB_DEBUG it is more than twice as big again.
> 
>  
> > > I'll see if I can get some basic dynamic memory numbers soon. The problem
> > > is that slub oopses on boot on the powerpc platform I'm testing on...
> > 
> > Please send me a full bug report.
> 
> It was on ppc and there seemed to still be some activity going on
> there at the time, so if it still breaks when I retest then I will
> send you a report.

There is a known issue for !CONFIG_SLUB_DEBUG and 2.6.21-rc1-mm1 and 
2.6.22-rc2. Just leave it on.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
