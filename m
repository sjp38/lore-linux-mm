Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k85GmALB031451
	for <linux-mm@kvack.org>; Tue, 5 Sep 2006 12:48:10 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k85Gm8nn296700
	for <linux-mm@kvack.org>; Tue, 5 Sep 2006 12:48:08 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k85Gm7E9027078
	for <linux-mm@kvack.org>; Tue, 5 Sep 2006 12:48:08 -0400
Subject: Re: [RFC][PATCH 3/9] actual generic PAGE_SIZE infrastructure
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20060905112056.GJ17042@admingilde.org>
References: <20060830221604.E7320C0F@localhost.localdomain>
	 <20060830221606.40937644@localhost.localdomain>
	 <20060905112056.GJ17042@admingilde.org>
Content-Type: text/plain
Date: Tue, 05 Sep 2006 09:47:43 -0700
Message-Id: <1157474863.3186.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Waitz <tali@admingilde.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2006-09-05 at 13:20 +0200, Martin Waitz wrote:
> On Wed, Aug 30, 2006 at 03:16:06PM -0700, Dave Hansen wrote:
> > * Define ASM_CONST() macro to help using constants in both assembly
> >   and C code.  Several architectures have some form of this, and
> >   they will be consolidated around this one.
> 
> arm uses UL() for this and I think this is much more readable than
> ASM_CONST().  Can we please change the name of this macro?

I don't have any real problem with changing it, but I fear that the ppc
guys will want it the _other_ way. ;)

Do you really mind if we just keep it as it is?  If there is some
further disagreement on it, I'll change it.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
