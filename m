Date: Wed, 23 May 2007 06:59:38 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 1/3] slob: rework freelist handling
Message-ID: <20070523045938.GA29045@wotan.suse.de>
References: <20070522073910.GD17051@wotan.suse.de> <20070522145345.GN11115@waste.org> <Pine.LNX.4.64.0705221216300.30149@schroedinger.engr.sgi.com> <20070523030637.GC9255@wotan.suse.de> <Pine.LNX.4.64.0705222154280.28140@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0705222154280.28140@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, May 22, 2007 at 09:55:07PM -0700, Christoph Lameter wrote:
> On Wed, 23 May 2007, Nick Piggin wrote:
> 
> > The only real numbers I have off-hand are these
> > 
> > $ size mm/slob.o
> >    text    data     bss     dec     hex filename
> >    4160     792       8    4960    1360 mm/slob.o
> > $ size mm/slub.o
> >    text    data     bss     dec     hex filename
> >   11728    6468     176   18372    47c4 mm/slub.o
>  
> 
> Thats with CONFIG_SLUB_DEBUG?

No. With CONFIG_SLUB_DEBUG it is more than twice as big again.

 
> > I'll see if I can get some basic dynamic memory numbers soon. The problem
> > is that slub oopses on boot on the powerpc platform I'm testing on...
> 
> Please send me a full bug report.

It was on ppc and there seemed to still be some activity going on
there at the time, so if it still breaks when I retest then I will
send you a report.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
