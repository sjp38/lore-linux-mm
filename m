Date: Tue, 14 Aug 2007 01:55:18 +0200
From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 3/4] Embed zone_id information within the zonelist->zones pointer
Message-ID: <20070813235518.GK3406@bingen.suse.de>
References: <200708110304.55433.ak@suse.de> <Pine.LNX.4.64.0708131423050.28026@schroedinger.engr.sgi.com> <20070813225020.GE3406@bingen.suse.de> <Pine.LNX.4.64.0708131457190.28445@schroedinger.engr.sgi.com> <20070813225841.GG3406@bingen.suse.de> <Pine.LNX.4.64.0708131506030.28502@schroedinger.engr.sgi.com> <20070813230801.GH3406@bingen.suse.de> <Pine.LNX.4.64.0708131518320.28626@schroedinger.engr.sgi.com> <20070813234217.GI3406@bingen.suse.de> <Pine.LNX.4.64.0708131550100.30626@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0708131550100.30626@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <ak@suse.de>, Mel Gorman <mel@skynet.ie>, Lee.Schermerhorn@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 13, 2007 at 03:52:54PM -0700, Christoph Lameter wrote:
> On Tue, 14 Aug 2007, Andi Kleen wrote:
> 
> > > I am not sure what you mean by that. Ia64 ZONE_DMA == x86_84 ZONE_DMA32?
> > 
> > Hmm, when I wrote GFP_DMA32 it was a #define GFP_DMA32 GFP_DMA 
> > on ia64 so that drivers not need to ifdef.  Someone nasty
> > seems to have removed that too. I guess it would be best
> > to readd.
> 
> What would be the point?

"so that drivers not need to ifdef" 

> > But then it wouldn't make sense to have GFP_DMA on ia64 and GFP_DMA32
> > on x86. Since driver writers are more likely to test on x86
> > I would recommend ia64 having compatible semantics. It'll
> > save everybody trouble long term. This means it wouldn't 
> > help on IA64 machines that don't have a DMA zone -- they
> > would still need to validate drivers especially -- but at least
> > the others.
> 
> There are no compatible semantics. ZONE_DMA may mean something different 

Yes current GFP_DMA is a mess.

But GFP_DMA32 is relatively clean and it means that same
as GFP_DMA on IA64. So ia64 could relatively painless switch
to it.

Anyways, I must admit ia64 is not my main concern. If you or Tony
don't like GFP_DMA32 then keep using GFP_DMA if you want, but just don't
complain about driver porting problems. I'm just trying to make
your lives easier (that is why i did the #define originally),
not be annoying.

> for each arch depending on its need. An arch may not have a need for a 4GB 
> boundary (such as s390).

I don't worry about s390 too much because the s390 driver universe
doesn't really overlap with the x86 driver universe. So whatever
semantics they have it's their own issue.

If they ever build s390s with PCI slots that can take arbitary card 
they might have an issue, but I won't worry about this.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
