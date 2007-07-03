Subject: Re: [PATCH] Re: Sparc32: random invalid instruction occourances on
	sparc32 (sun4c)
From: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <Pine.LNX.4.61.0707031910280.29930@mtfhpc.demon.co.uk>
References: <468A7D14.1050505@googlemail.com>
	 <Pine.LNX.4.61.0707031817050.29930@mtfhpc.demon.co.uk>
	 <Pine.LNX.4.61.0707031910280.29930@mtfhpc.demon.co.uk>
Content-Type: text/plain
Date: Tue, 03 Jul 2007 15:26:18 -0400
Message-Id: <1183490778.29081.35.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Fortescue <mark@mtfhpc.demon.co.uk>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, sparclinux@vger.kernel.org, David Miller <davem@davemloft.net>, Christoph Lameter <clameter@engr.sgi.com>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-07-03 at 19:57 +0100, Mark Fortescue wrote:
> > Commit b46b8f19c9cd435ecac4d9d12b39d78c137ecd66 partially fixed alignment 
> > issues but does not ensure that all 64bit alignment requirements of sparc32 
> > are met. Tests have shown that the redzone2 word can become misallignd.

Oops, sorry about that. I'm not sure about your patch though -- I think
I'd prefer to keep the redzone misaligned (and hence _right_ next to the
real data), and just deal with it.

typedef unsigned long long __aligned__((BYTES_PER_WORD)) redzone_t;

-- 
dwmw2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
