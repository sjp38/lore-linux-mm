Date: Tue, 17 Feb 2004 23:22:18 +0100
From: David Weinehall <tao@acc.umu.se>
Subject: Re: Non-GPL export of invalidate_mmap_range
Message-ID: <20040217222218.GF2125@khan.acc.umu.se>
References: <20040216190927.GA2969@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040216190927.GA2969@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Paul E. McKenney" <paulmck@us.ibm.com>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 16, 2004 at 11:09:27AM -0800, Paul E. McKenney wrote:
> Hello, Andrew,
> 
> The attached patch to make invalidate_mmap_range() non-GPL exported
> seems to have been lost somewhere between 2.6.1-mm4 and 2.6.1-mm5.
> It still applies cleanly.  Could you please take it up again?
> 
> 						Thanx, Paul
> 
> ------------------------------------------------------------------------
> 
> 
> 
> It was EXPORT_SYMBOL_GPL(), however IBM's GPFS is not GPL.

Ahhh, but it would be really nice if it was, even if it's irksome to get
decent performance out of it ;-)

[snip]


Regards: David Weinehall
-- 
 /) David Weinehall <tao@acc.umu.se> /) Northern lights wander      (\
//  Maintainer of the v2.0 kernel   //  Dance across the winter sky //
\)  http://www.acc.umu.se/~tao/    (/   Full colour fire           (/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
