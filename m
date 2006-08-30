Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7UMmEQ6007457
	for <linux-mm@kvack.org>; Wed, 30 Aug 2006 18:48:14 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7UMmEgR270102
	for <linux-mm@kvack.org>; Wed, 30 Aug 2006 16:48:14 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7UMmDjB009340
	for <linux-mm@kvack.org>; Wed, 30 Aug 2006 16:48:14 -0600
Subject: Re: [RFC][PATCH 7/9] parisc generic PAGE_SIZE
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20060830224054.GG3926@athena.road.mcmartin.ca>
References: <20060830221604.E7320C0F@localhost.localdomain>
	 <20060830221609.DA8E9016@localhost.localdomain>
	 <20060830224054.GG3926@athena.road.mcmartin.ca>
Content-Type: text/plain
Date: Wed, 30 Aug 2006 15:48:05 -0700
Message-Id: <1156978085.31295.18.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kyle McMartin <kyle@parisc-linux.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2006-08-30 at 18:40 -0400, Kyle McMartin wrote:
> On Wed, Aug 30, 2006 at 03:16:09PM -0700, Dave Hansen wrote:
> > This is the parisc portion to convert it over to the generic PAGE_SIZE
> > framework.
> > 
> <snip>
> > Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
> 
> This looks pretty ok by me. I'll give it a test-build tonight.

That'd be great.  Thanks!

> > +config PARISC_LARGER_PAGE_SIZES
> > +	def_bool y
> >  	depends on PA8X00 && EXPERIMENTAL
> >  
> 
> This should default to 'n' as I do not believe we yet have working >4K
> pages yet.

This actually just defaults to enables the option to _appear_ in the
top-level Kconfig file.  The default from the top-level Kconfig file
should still be 4k for parisc.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
