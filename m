Date: Fri, 7 Mar 2008 16:31:36 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [0/13] General DMA zone rework
Message-ID: <20080307153136.GG7365@one.firstfloor.org>
References: <200803071007.493903088@firstfloor.org> <47D15CDF.5060501@keyaccess.nl> <47D15DA4.2030500@keyaccess.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <47D15DA4.2030500@keyaccess.nl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rene Herman <rene.herman@keyaccess.nl>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 07, 2008 at 04:22:12PM +0100, Rene Herman wrote:
> On 07-03-08 16:18, Rene Herman wrote:
> 
> >On 07-03-08 10:07, Andi Kleen wrote:
> >
> >>it to any size needed (upto 2GB currently). The default sizing 
> >>heuristics are for now the same as in the old code: by default
> >>all free memory below 16MB is put into the pool (in practice that
> >>is only ~8MB or so usable because the kernel is loaded there too)
> >
> >Just a side-comment -- not necessarily, given CONFIG_PHYSICAL_START.
> 
> By the way, 1/13 didn't make it to LKML.

Yes, i was told. Not sure what happened. I'm pretty sure my script
has posted it. If anybody wants it it's in
ftp://firstfloor.org/pub/ak/mask/patches/bitops

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
