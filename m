Subject: Re: [PATCH/RFC] Rework ptep_set_access_flags and fix sun4c
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <Pine.LNX.4.61.0705222247010.5890@mtfhpc.demon.co.uk>
References: <Pine.LNX.4.61.0705012354290.12808@mtfhpc.demon.co.uk>
	 <20070509231937.ea254c26.akpm@linux-foundation.org>
	 <1178778583.14928.210.camel@localhost.localdomain>
	 <20070510.001234.126579706.davem@davemloft.net>
	 <Pine.LNX.4.64.0705142018090.18453@blonde.wat.veritas.com>
	 <1179176845.32247.107.camel@localhost.localdomain>
	 <1179212184.32247.163.camel@localhost.localdomain>
	 <1179757647.6254.235.camel@localhost.localdomain>
	 <1179815339.32247.799.camel@localhost.localdomain>
	 <Pine.LNX.4.61.0705222247010.5890@mtfhpc.demon.co.uk>
Content-Type: text/plain
Date: Wed, 23 May 2007 09:28:14 +1000
Message-Id: <1179876494.32247.887.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Fortescue <mark@mtfhpc.demon.co.uk>
Cc: "Tom \"spot\" Callaway" <tcallawa@redhat.com>, Hugh Dickins <hugh@veritas.com>, David Miller <davem@davemloft.net>, akpm@linux-foundation.org, linuxppc-dev@ozlabs.org, wli@holomorphy.com, linux-mm@kvack.org, andrea@suse.de, sparclinux@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2007-05-22 at 22:52 +0100, Mark Fortescue wrote:
> Hi Benjamin,
> 
> I have just tested this patch on my Sun4c Sparcstation 1 using my 2.6.20.9 
> test kernel without any problems.
> 
> Thank you for the work.

Wow, there is more than one user of these still ! :-)

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
