Subject: Re: [PATCH/RFC] Rework ptep_set_access_flags and fix sun4c
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20070522.145340.59657045.davem@davemloft.net>
References: <1179757647.6254.235.camel@localhost.localdomain>
	 <1179815339.32247.799.camel@localhost.localdomain>
	 <Pine.LNX.4.61.0705222247010.5890@mtfhpc.demon.co.uk>
	 <20070522.145340.59657045.davem@davemloft.net>
Content-Type: text/plain
Date: Wed, 23 May 2007 09:29:14 +1000
Message-Id: <1179876554.32247.889.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: mark@mtfhpc.demon.co.uk, tcallawa@redhat.com, hugh@veritas.com, akpm@linux-foundation.org, linuxppc-dev@ozlabs.org, wli@holomorphy.com, linux-mm@kvack.org, andrea@suse.de, sparclinux@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2007-05-22 at 14:53 -0700, David Miller wrote:
> From: Mark Fortescue <mark@mtfhpc.demon.co.uk>
> Date: Tue, 22 May 2007 22:52:13 +0100 (BST)
> 
> > Hi Benjamin,
> > 
> > I have just tested this patch on my Sun4c Sparcstation 1 using my 2.6.20.9 
> > test kernel without any problems.
> > 
> > Thank you for the work.
> 
> Thanks for your testing.
> 
> Someone please merge this in once any remaining issues have
> been resolved :-)

I'll send a patch fixing the couple of x86/ia64 nits & my bad english
spelling (no, I don't happen to raise castrated rams) as soon as I reach
the office later today.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
