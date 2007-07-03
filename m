Date: Tue, 3 Jul 2007 22:25:24 +0100 (BST)
From: Mark Fortescue <mark@mtfhpc.demon.co.uk>
Subject: Re: [PATCH] Re: Sparc32: random invalid instruction occourances on
 sparc32 (sun4c)
In-Reply-To: <1183490778.29081.35.camel@shinybook.infradead.org>
Message-ID: <Pine.LNX.4.61.0707032209230.30376@mtfhpc.demon.co.uk>
References: <468A7D14.1050505@googlemail.com>  <Pine.LNX.4.61.0707031817050.29930@mtfhpc.demon.co.uk>
  <Pine.LNX.4.61.0707031910280.29930@mtfhpc.demon.co.uk>
 <1183490778.29081.35.camel@shinybook.infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, sparclinux@vger.kernel.org, David Miller <davem@davemloft.net>, Christoph Lameter <clameter@engr.sgi.com>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

Hi David,

The problem is that sun4c Sparc32 can't handle un-aligned variables so 
having a 64bit readzone word that is not aligned on a 64bit boundary is a 
problem.

In addition, having looked at the size calculations, it looks to me as if 
not all of them got updated to handle 64bit redzone words. This may be part of 
the problem. By making BYTES_PER_WORD 64bit aligned (Sparc32) this is 
nolonger an issue.

Regards
 	Mark Fortescue.

On Tue, 3 Jul 2007, David Woodhouse wrote:

> On Tue, 2007-07-03 at 19:57 +0100, Mark Fortescue wrote:
>>> Commit b46b8f19c9cd435ecac4d9d12b39d78c137ecd66 partially fixed alignment
>>> issues but does not ensure that all 64bit alignment requirements of sparc32
>>> are met. Tests have shown that the redzone2 word can become misallignd.
>
> Oops, sorry about that. I'm not sure about your patch though -- I think
> I'd prefer to keep the redzone misaligned (and hence _right_ next to the
> real data), and just deal with it.
>
> typedef unsigned long long __aligned__((BYTES_PER_WORD)) redzone_t;
>
> -- 
> dwmw2
>
> -
> To unsubscribe from this list: send the line "unsubscribe sparclinux" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
