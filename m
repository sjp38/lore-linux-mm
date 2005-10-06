Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.12.10/8.12.10) with ESMTP id j967ecO0130886
	for <linux-mm@kvack.org>; Thu, 6 Oct 2005 07:40:38 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j967ecZ2175652
	for <linux-mm@kvack.org>; Thu, 6 Oct 2005 09:40:38 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id j967ecYo022828
	for <linux-mm@kvack.org>; Thu, 6 Oct 2005 09:40:38 +0200
Date: Thu, 6 Oct 2005 09:39:43 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: sparsemem & sparsemem extreme question
Message-ID: <20051006073943.GA2482@osiris.boeblingen.de.ibm.com>
References: <20051005155823.GA10119@osiris.ibm.com> <1128528340.26009.8.camel@localhost> <20051005161009.GA10146@osiris.ibm.com> <1128529222.26009.16.camel@localhost> <20051005171230.GA10204@osiris.ibm.com> <1128532809.26009.39.camel@localhost> <20051005174542.GB10204@osiris.ibm.com> <1128535054.26009.53.camel@localhost> <20051005180443.GC10204@osiris.ibm.com> <1128550002.18249.14.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1128550002.18249.14.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, Bob Picco <bob.picco@hp.com>
List-ID: <linux-mm.kvack.org>

> > As already mentioned, we will have physical memory with the MSB set. Afaik
> > the hardware uses this bit to distinguish between different types of memory.
> > So we are going to have the full 64 bit address space.
> Is it just the MSB?  If so, we can probably just shift it down to some
> reasonable address.  The only issue comes if you really have the whole
> address space used in some random way.

Unfortunately there is more than just the MSB. If the MSB is set then there
will be a 'model dependent' number of bits just below the MSB used to encode
whatever the hardware thinks is necessary. Also you cannot tell how these
bits will be set from an operating system's view. Best thing to do is to
assume nothing and leave the addresses alone.

Heiko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
