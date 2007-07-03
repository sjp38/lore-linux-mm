Subject: Re: [PATCH] Re: Sparc32: random invalid instruction occourances on
	sparc32 (sun4c)
From: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <20070703.144112.24611353.davem@davemloft.net>
References: <Pine.LNX.4.61.0707031817050.29930@mtfhpc.demon.co.uk>
	 <Pine.LNX.4.61.0707031910280.29930@mtfhpc.demon.co.uk>
	 <1183490778.29081.35.camel@shinybook.infradead.org>
	 <20070703.144112.24611353.davem@davemloft.net>
Content-Type: text/plain
Date: Tue, 03 Jul 2007 18:01:36 -0400
Message-Id: <1183500096.29081.51.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: mark@mtfhpc.demon.co.uk, linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, clameter@engr.sgi.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Tue, 2007-07-03 at 14:41 -0700, David Miller wrote:
> Please don't use get_unaligned() or whatever to fix this, it's
> going to generate the byte-at-a-time accesses on sparc64
> which doesn't need it since the redzone will be aligned. 

Yes, get_unaligned() would suck. But 'u64 __aligned__((BYTES_PER_WORD))'
as I suggested should result in a single 64-bit load on 64-bit
architectures, and two 32-bit loads on 32-bit architectures.

But I think the patch I just sent is a better option than that anyway.

-- 
dwmw2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
