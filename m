Date: Fri, 19 Nov 2004 17:58:25 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: page fault scalability patch V11 [0/7]: overview
In-Reply-To: <Pine.LNX.4.58.0411191726001.1719@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.58.0411191757250.2222@ppc970.osdl.org>
References: <Pine.LNX.4.44.0411061527440.3567-100000@localhost.localdomain>
  <Pine.LNX.4.58.0411181126440.30385@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0411181715280.834@schroedinger.engr.sgi.com>
 <419D581F.2080302@yahoo.com.au>  <Pine.LNX.4.58.0411181835540.1421@schroedinger.engr.sgi.com>
  <419D5E09.20805@yahoo.com.au>  <Pine.LNX.4.58.0411181921001.1674@schroedinger.engr.sgi.com>
 <1100848068.25520.49.camel@gaston> <Pine.LNX.4.58.0411190704330.5145@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0411191155180.2222@ppc970.osdl.org> <419E98E7.1080402@yahoo.com.au>
 <Pine.LNX.4.58.0411191726001.1719@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, akpm@osdl.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Fri, 19 Nov 2004, Christoph Lameter wrote:
> 
> Note though that the mmap_sem is no protection. It is a read lock and may
> be held by multiple processes while incrementing and decrementing rss.
> This is likely reducing the number of collisions significantly but it wont
> be a  guarantee like locking or atomic ops.

It is, though, if you hold it for a write.

The point being that you _can_ get an exact rss value if you want to.

Not that I really see any overwhelming evidence of anybody ever really 
caring, but it's nice to know that you have the option.

		Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
