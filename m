Date: Tue, 03 Jul 2007 14:41:12 -0700 (PDT)
Message-Id: <20070703.144112.24611353.davem@davemloft.net>
Subject: Re: [PATCH] Re: Sparc32: random invalid instruction occourances on
 sparc32 (sun4c)
From: David Miller <davem@davemloft.net>
In-Reply-To: <1183490778.29081.35.camel@shinybook.infradead.org>
References: <Pine.LNX.4.61.0707031817050.29930@mtfhpc.demon.co.uk>
	<Pine.LNX.4.61.0707031910280.29930@mtfhpc.demon.co.uk>
	<1183490778.29081.35.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: David Woodhouse <dwmw2@infradead.org>
Date: Tue, 03 Jul 2007 15:26:18 -0400
Return-Path: <owner-linux-mm@kvack.org>
To: dwmw2@infradead.org
Cc: mark@mtfhpc.demon.co.uk, linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, clameter@engr.sgi.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

> On Tue, 2007-07-03 at 19:57 +0100, Mark Fortescue wrote:
> > > Commit b46b8f19c9cd435ecac4d9d12b39d78c137ecd66 partially fixed alignment 
> > > issues but does not ensure that all 64bit alignment requirements of sparc32 
> > > are met. Tests have shown that the redzone2 word can become misallignd.
> 
> Oops, sorry about that. I'm not sure about your patch though -- I think
> I'd prefer to keep the redzone misaligned (and hence _right_ next to the
> real data), and just deal with it.
> 
> typedef unsigned long long __aligned__((BYTES_PER_WORD)) redzone_t;

Please don't use get_unaligned() or whatever to fix this, it's
going to generate the byte-at-a-time accesses on sparc64
which doesn't need it since the redzone will be aligned.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
