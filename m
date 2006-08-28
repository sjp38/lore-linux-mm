Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7SHjb5b022701
	for <linux-mm@kvack.org>; Mon, 28 Aug 2006 13:45:37 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7SHjbMq281848
	for <linux-mm@kvack.org>; Mon, 28 Aug 2006 13:45:37 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7SHjbBj023080
	for <linux-mm@kvack.org>; Mon, 28 Aug 2006 13:45:37 -0400
Subject: Re: [RFC][PATCH 2/7] ia64 generic PAGE_SIZE
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.64.0608281029550.27837@schroedinger.engr.sgi.com>
References: <20060828154413.E05721BD@localhost.localdomain>
	 <20060828154414.38AEDAA2@localhost.localdomain>
	 <Pine.LNX.4.64.0608281003070.27677@schroedinger.engr.sgi.com>
	 <1156785773.5913.38.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0608281029550.27837@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 28 Aug 2006 10:45:34 -0700
Message-Id: <1156787134.5913.47.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2006-08-28 at 10:32 -0700, Christoph Lameter wrote:
> Lets keep the arch specific stuff out of mm/Kconfig.

I know that the normal way of doing things has been with
ARCH_SUPPORTS_FOO defined in arch/Kconfig.  But, I really like the
alternate approach because it is so easy to figure out which
architectures support which page sizes with a single glance at the
Kconfig file.  

I can really see putting another layer of indirection in there if things
were too complicated to understand at a glance, but I think they've
remained pretty simple.

Is there any specific reason that you dislike the arch-specific stuff in
mm/Kconfig?

I don't mind creating those other Kconfig options, but I'm not really
sure I see a concrete reason for it, yet.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
