Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7VHciOM030978
	for <linux-mm@kvack.org>; Thu, 31 Aug 2006 13:38:44 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7VHcg1b280948
	for <linux-mm@kvack.org>; Thu, 31 Aug 2006 13:38:44 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7VHcgBF011382
	for <linux-mm@kvack.org>; Thu, 31 Aug 2006 13:38:42 -0400
Subject: Re: [RFC][PATCH 4/9] ia64 generic PAGE_SIZE
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.64.0608301652270.5789@schroedinger.engr.sgi.com>
References: <20060830221604.E7320C0F@localhost.localdomain>
	 <20060830221607.1DB81421@localhost.localdomain>
	 <Pine.LNX.4.64.0608301652270.5789@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 31 Aug 2006 10:38:30 -0700
Message-Id: <1157045910.31295.23.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2006-08-30 at 16:57 -0700, Christoph Lameter wrote:
> On Wed, 30 Aug 2006, Dave Hansen wrote:
> 
> > @@ -64,11 +64,11 @@
> >   * Base-2 logarithm of number of pages to allocate per task structure
> >   * (including register backing store and memory stack):
> >   */
> > -#if defined(CONFIG_IA64_PAGE_SIZE_4KB)
> > +#if defined(CONFIG_PAGE_SIZE_4KB)
> >  # define KERNEL_STACK_SIZE_ORDER		3
> > -#elif defined(CONFIG_IA64_PAGE_SIZE_8KB)
> > +#elif defined(CONFIG_PAGE_SIZE_8KB)
> >  # define KERNEL_STACK_SIZE_ORDER		2
> > -#elif defined(CONFIG_IA64_PAGE_SIZE_16KB)
> > +#elif defined(CONFIG_PAGE_SIZE_16KB)
> >  # define KERNEL_STACK_SIZE_ORDER		1
> >  #else
> >  # define KERNEL_STACK_SIZE_ORDER		0
> 
> Could we replace these lines with
> 
> #define KERNEL_STACK_SIZE_ORDER (max(0, 15 - PAGE_SHIFT)) 

My next series will be to clean up stack size handling.  Do you mind if
it waits until then?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
