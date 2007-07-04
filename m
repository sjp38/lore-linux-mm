Subject: Re: [PATCH] Re: Sparc32: random invalid instruction occourances on
	sparc32 (sun4c)
From: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <Pine.LNX.4.61.0707040335230.30946@mtfhpc.demon.co.uk>
References: <468A7D14.1050505@googlemail.com>
	 <Pine.LNX.4.61.0707031817050.29930@mtfhpc.demon.co.uk>
	 <Pine.LNX.4.61.0707031910280.29930@mtfhpc.demon.co.uk>
	 <1183490778.29081.35.camel@shinybook.infradead.org>
	 <Pine.LNX.4.61.0707032209230.30376@mtfhpc.demon.co.uk>
	 <1183499781.29081.46.camel@shinybook.infradead.org>
	 <Pine.LNX.4.61.0707032317590.30376@mtfhpc.demon.co.uk>
	 <1183505787.29081.62.camel@shinybook.infradead.org>
	 <Pine.LNX.4.61.0707040335230.30946@mtfhpc.demon.co.uk>
Content-Type: text/plain
Date: Tue, 03 Jul 2007 23:33:25 -0400
Message-Id: <1183520006.29081.79.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Fortescue <mark@mtfhpc.demon.co.uk>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, sparclinux@vger.kernel.org, David Miller <davem@davemloft.net>, Christoph Lameter <clameter@engr.sgi.com>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-07-04 at 04:27 +0100, Mark Fortescue wrote:
> I tried the previous patch and it looks like it fixes the issue however 
> one of the test builds I did caused depmod to use up all available memory 
> (40M - kernel memory) before taking out the kernel with the oom killer.
> At present, I do not know if it is a depmod issue or a kernel issue.
> I will have to do some more tests later on to day.

That's almost certain to be an unrelated issue.

> I have looked at the latest patch below and am I am still not sure about 
> two areas. Please take a look at my offering based on your latest 
> patch (included here to it will probably get mangled).
> 
> Note the change to lines 2178 to 2185. I have also changed/moved the 
> alignment of size (see lines 2197 to 2206) based on your changes. 

The first looks correct; well spotted. The second is just cosmetic but
also seems correct. I might be inclined to make the #define
'RED_ZONE_ALIGN' and use it in the other places too.

-- 
dwmw2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
