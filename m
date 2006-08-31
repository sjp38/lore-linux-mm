Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7VL3M65003182
	for <linux-mm@kvack.org>; Thu, 31 Aug 2006 17:03:22 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7VL3Mxe285860
	for <linux-mm@kvack.org>; Thu, 31 Aug 2006 17:03:22 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7VL3Mw3020065
	for <linux-mm@kvack.org>; Thu, 31 Aug 2006 17:03:22 -0400
Subject: Re: [RFC][PATCH 0/9] generic PAGE_SIZE infrastructure (v4)
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <17654.11889.933070.539839@cargo.ozlabs.ibm.com>
References: <20060830221604.E7320C0F@localhost.localdomain>
	 <17654.11889.933070.539839@cargo.ozlabs.ibm.com>
Content-Type: text/plain
Date: Thu, 31 Aug 2006 14:03:12 -0700
Message-Id: <1157058192.28577.33.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mackerras <paulus@samba.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2006-08-31 at 10:33 +1000, Paul Mackerras wrote:
> Dave Hansen writes:
> > Why am I doing this?  The OpenVZ beancounter patch hooks into the
> > alloc_thread_info() path, but only in two architectures.  It is silly
> > to patch each and every architecture when they all just do the same
> > thing.  This is the first step to have a single place in which to
> > do alloc_thread_info().  Oh, and this series removes about 300 lines
> > of code.
> 
> ... at the price of making the Kconfig help text more generic and
> therefore possibly confusing on some platforms.
> 
> I really don't see much value in doing all this.

The value for me is that this makes it much easier to add generic kernel
features.  There have been way too many times that I've made some
arch-independent change which required going and fixing up the *same*
code in every single architecture.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
