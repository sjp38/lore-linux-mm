Date: Fri, 7 Mar 2008 18:43:16 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [6/13] Core maskable allocator
Message-ID: <20080307174316.GJ7365@one.firstfloor.org>
References: <200803071007.493903088@firstfloor.org> <20080307090716.9D3E91B419C@basil.firstfloor.org> <20080307090517.b6b27987.randy.dunlap@oracle.com> <20080307173146.GI7365@one.firstfloor.org> <47D17C4E.9000302@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <47D17C4E.9000302@oracle.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 07, 2008 at 09:33:02AM -0800, Randy Dunlap wrote:
> Andi Kleen wrote:
> >>>+	maskzone=size[MG] Set size of maskable DMA zone to size.
> >>>+		 force	Always allocate from the mask zone (for testing)
> >>                 ^^^^^^^^^^^^^ ??
> >
> >What is your question?
> 
> That line seems odd.  Is it correct?
> Why 2 spaces between force and Always?  Why is Always capitalized?
> Could one of those words be dropped?  They seem a bit redundant.

The option is either maskzone=size[MG] or maskzone=force
Each followed with a sentence describing them.

I tried to make this clear by lining them up, but apparently failed.
You have a preferred way to formatting such multiple choice options?

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
