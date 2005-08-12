Subject: Re: Zoned CART
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <42FCC359.20200@andrew.cmu.edu>
References: <1123857429.14899.59.camel@twins>
	 <42FCC359.20200@andrew.cmu.edu>
Content-Type: text/plain
Date: Fri, 12 Aug 2005 17:52:51 +0200
Message-Id: <1123861971.14899.66.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rahul Iyer <rni@andrew.cmu.edu>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2005-08-12 at 11:42 -0400, Rahul Iyer wrote:
> Hi Peter,
> I have recently released another patch...
> both patches are at http://www.cs.cmu.edu/~412/projects/CART/

> >I shall attempt to merge this code into the Rahuls new cart-patch-2 if
> >you guys don't see any big problems with the approach, or beat me to it.
> >

Yes I've seen that, that's the one I refered to in the above line.
I still have to read it thorougly though; however it looks as if the
non-resident pages are still per zone. Also you yourself mention OOM
problems with allocating nodes for the lists.

I hope my code solves those problems without affecting the quality of
the algorithm.

Peter Zijlstra

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
