Date: Fri, 7 Mar 2008 12:14:52 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [6/13] Core maskable allocator
Message-ID: <20080307111452.GA7365@one.firstfloor.org>
References: <200803071007.493903088@firstfloor.org> <20080307090716.9D3E91B419C@basil.firstfloor.org> <871w6m955h.fsf@saeurebad.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <871w6m955h.fsf@saeurebad.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Weiner <hannes@saeurebad.de>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > +		}
> > +#endif
> > +		p = alloc_pages(gfp_mask|__GFP_NOWARN, order);
> 
> ... isn't this a leak here?

You're right -- this needs a check. Weird wonder why the tests didn't
catch that.

Thanks,
-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
