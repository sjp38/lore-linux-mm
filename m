Date: Mon, 1 Aug 2005 11:18:42 -0700 (PDT)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [patch 2.6.13-rc4] fix get_user_pages bug
In-Reply-To: <Pine.LNX.4.58.0508010833250.14342@g5.osdl.org>
Message-ID: <Pine.LNX.4.58.0508011116180.3341@g5.osdl.org>
References: <20050801032258.A465C180EC0@magilla.sf.frob.com>
 <42EDDB82.1040900@yahoo.com.au> <Pine.LNX.4.58.0508010833250.14342@g5.osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Robin Holt <holt@sgi.com>, Andrew Morton <akpm@osdl.org>, Roland McGrath <roland@redhat.com>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 1 Aug 2005, Linus Torvalds wrote:
> 
> Ie something like the below (which is totally untested, obviously, but I 
> think conceptually is a lot more correct, and obviously a lot simpler).

I've tested it, and thought more about it, and I can't see any fault with
the approach. In fact, I like it more. So it's checked in now (in a
further simplified way, since the thing made "lookup_write" always be the
same as just "write").

Can somebody who saw the problem in the first place please verify?

		Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
