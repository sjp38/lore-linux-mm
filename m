Date: Tue, 1 Feb 2005 16:05:09 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2/2] Helping prezoring with reduced fragmentation allocation
In-Reply-To: <Pine.LNX.4.58.0502011929020.16992@skynet>
Message-ID: <Pine.LNX.4.58.0502011604130.5406@schroedinger.engr.sgi.com>
References: <20050201171641.CC15EE5E8@skynet.csn.ul.ie>
 <Pine.LNX.4.58.0502011110560.3436@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0502011929020.16992@skynet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 1 Feb 2005, Mel Gorman wrote:

> > Would it not be better to zero the global 2^MAX_ORDER pages by the scrub
> > daemon and have a global zeroed page list? That way you may avoid zeroing
> > when splitting pages?
> >
>
> Maybe, but right now when there are no 2^MAX_ORDER pages, the scrub daemon
> is going to be doing nothing which is why I think it needs to look at the
> free pages of lower orders.
>
> That is solveable though in one of two ways. One, the scrub daemon can
> zero pages from the global list and then add them to the USERZERO pool. It
> has the advantage of requiring no more memory and is simple. The second is
> to create a second global list. However, I think it only makes sense to
> have this as part of the scrub daemon patch (I can write it if thats a
> problem) rather than a standalone patch from me.

Approach one is fine and I will do an update the remaining prezero patches
to do just that. When will your patches be in Linus tree? ;-)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
