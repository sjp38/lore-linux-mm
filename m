Date: Sat, 2 Oct 2004 13:06:58 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [RFC] memory defragmentation to satisfy high order allocations
Message-ID: <20041002160658.GC7501@logos.cnet>
References: <20041001182221.GA3191@logos.cnet> <415E154A.2040209@cyberone.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <415E154A.2040209@cyberone.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: linux-mm@kvack.org, akpm@osdl.org, arjanv@redhat.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, Oct 02, 2004 at 12:41:14PM +1000, Nick Piggin wrote:
> 
> 
> Marcelo Tosatti wrote:
> 
> >
> >For example it doesnt re establishes pte's once it has unmapped them.
> >
> >
> 
> Another thing - I don't know if I'd bother re-establishing ptes....
> I'd say just leave it to happen lazily at fault time.

Indeed it should work lazily.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
