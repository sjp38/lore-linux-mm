Date: Tue, 22 May 2007 14:53:40 -0700 (PDT)
Message-Id: <20070522.145340.59657045.davem@davemloft.net>
Subject: Re: [PATCH/RFC] Rework ptep_set_access_flags and fix sun4c
From: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.61.0705222247010.5890@mtfhpc.demon.co.uk>
References: <1179757647.6254.235.camel@localhost.localdomain>
	<1179815339.32247.799.camel@localhost.localdomain>
	<Pine.LNX.4.61.0705222247010.5890@mtfhpc.demon.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Mark Fortescue <mark@mtfhpc.demon.co.uk>
Date: Tue, 22 May 2007 22:52:13 +0100 (BST)
Return-Path: <owner-linux-mm@kvack.org>
To: mark@mtfhpc.demon.co.uk
Cc: benh@kernel.crashing.org, tcallawa@redhat.com, hugh@veritas.com, akpm@linux-foundation.org, linuxppc-dev@ozlabs.org, wli@holomorphy.com, linux-mm@kvack.org, andrea@suse.de, sparclinux@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Hi Benjamin,
> 
> I have just tested this patch on my Sun4c Sparcstation 1 using my 2.6.20.9 
> test kernel without any problems.
> 
> Thank you for the work.

Thanks for your testing.

Someone please merge this in once any remaining issues have
been resolved :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
