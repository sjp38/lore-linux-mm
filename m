Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j95M6jaF022312
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 18:06:45 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j95M6i08035060
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 18:06:44 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j95M6iF5004176
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 18:06:44 -0400
Subject: Re: sparsemem & sparsemem extreme question
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20051005180443.GC10204@osiris.ibm.com>
References: <20051005063909.GA9699@osiris.boeblingen.de.ibm.com>
	 <1128527554.26009.2.camel@localhost>
	 <20051005155823.GA10119@osiris.ibm.com>
	 <1128528340.26009.8.camel@localhost>
	 <20051005161009.GA10146@osiris.ibm.com>
	 <1128529222.26009.16.camel@localhost>
	 <20051005171230.GA10204@osiris.ibm.com>
	 <1128532809.26009.39.camel@localhost>
	 <20051005174542.GB10204@osiris.ibm.com>
	 <1128535054.26009.53.camel@localhost>
	 <20051005180443.GC10204@osiris.ibm.com>
Content-Type: text/plain
Date: Wed, 05 Oct 2005 15:06:42 -0700
Message-Id: <1128550002.18249.14.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, Bob Picco <bob.picco@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2005-10-05 at 20:04 +0200, Heiko Carstens wrote: 
> As already mentioned, we will have physical memory with the MSB set. Afaik
> the hardware uses this bit to distinguish between different types of memory.
> So we are going to have the full 64 bit address space.

Is it just the MSB?  If so, we can probably just shift it down to some
reasonable address.  The only issue comes if you really have the whole
address space used in some random way.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
