Date: Wed, 15 Aug 2007 00:16:16 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC 4/9] Atomic reclaim: Save irq flags in vmscan.c
Message-ID: <20070814221616.GG23308@one.firstfloor.org>
References: <20070814204454.GC22202@one.firstfloor.org> <Pine.LNX.4.64.0708141414260.31693@schroedinger.engr.sgi.com> <20070814212355.GA23308@one.firstfloor.org> <Pine.LNX.4.64.0708141425000.31693@schroedinger.engr.sgi.com> <20070814212955.GC23308@one.firstfloor.org> <Pine.LNX.4.64.0708141436380.31693@schroedinger.engr.sgi.com> <20070814214430.GD23308@one.firstfloor.org> <Pine.LNX.4.64.0708141444590.32110@schroedinger.engr.sgi.com> <20070814215659.GF23308@one.firstfloor.org> <Pine.LNX.4.64.0708141504350.32420@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0708141504350.32420@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 14, 2007 at 03:07:10PM -0700, Christoph Lameter wrote:
> There are more spinlocks needed. So we would just check the whole bunch 
> and fail if any of them are used?

Yes zone_flag would apply to all of them.

> 
> > 		do things with zone locks 
> > 	}
> > 
> > The interrupt handler shouldn't touch zone_flag. If it wants
> > to it would need to be converted to a local_t and incremented/decremented
> > (should be about the same cost at least on architectures with sane
> > local_t implementation) 
> 
> That would mean we need to fork the code for reclaim?

Not with the local_t increment.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
