Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j95HKGZ3014485
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 13:20:16 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j95HKGt2089682
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 13:20:16 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j95HKGJ9021118
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 13:20:16 -0400
Subject: Re: sparsemem & sparsemem extreme question
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20051005171230.GA10204@osiris.ibm.com>
References: <20051004065030.GA21741@osiris.boeblingen.de.ibm.com>
	 <1128442502.20208.6.camel@localhost>
	 <20051005063909.GA9699@osiris.boeblingen.de.ibm.com>
	 <1128527554.26009.2.camel@localhost>
	 <20051005155823.GA10119@osiris.ibm.com>
	 <1128528340.26009.8.camel@localhost>
	 <20051005161009.GA10146@osiris.ibm.com>
	 <1128529222.26009.16.camel@localhost>
	 <20051005171230.GA10204@osiris.ibm.com>
Content-Type: text/plain
Date: Wed, 05 Oct 2005 10:20:09 -0700
Message-Id: <1128532809.26009.39.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2005-10-05 at 19:12 +0200, Heiko Carstens wrote:
> > > That's a matter of fact and what the Specs say...
> > I'd appreciate any pointer to the relevant information, especially the
> > stuff that explains just how sparse a physical address space can be on
> > that architecture.  What would discontigmem have done with the same
> > layout?  Does s390 even support discontigmem?
> 
> s390 does not support discontigmem at all. And unfortunately the
> documentation is not publicly available yet, sorry.
> Anything specific you need to know about the memory layout?

How sparse is it?  How few present pages can be there be in a worst-case
physical area?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
