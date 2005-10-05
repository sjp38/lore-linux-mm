Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j95Hvh5J002485
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 13:57:43 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j95Hvgt2094050
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 13:57:42 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j95Hvf8R008565
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 13:57:42 -0400
Subject: Re: sparsemem & sparsemem extreme question
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20051005174542.GB10204@osiris.ibm.com>
References: <20051004065030.GA21741@osiris.boeblingen.de.ibm.com>
	 <1128442502.20208.6.camel@localhost>
	 <20051005063909.GA9699@osiris.boeblingen.de.ibm.com>
	 <1128527554.26009.2.camel@localhost>
	 <20051005155823.GA10119@osiris.ibm.com>
	 <1128528340.26009.8.camel@localhost>
	 <20051005161009.GA10146@osiris.ibm.com>
	 <1128529222.26009.16.camel@localhost>
	 <20051005171230.GA10204@osiris.ibm.com>
	 <1128532809.26009.39.camel@localhost>
	 <20051005174542.GB10204@osiris.ibm.com>
Content-Type: text/plain
Date: Wed, 05 Oct 2005 10:57:34 -0700
Message-Id: <1128535054.26009.53.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, Bob Picco <bob.picco@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2005-10-05 at 19:45 +0200, Heiko Carstens wrote:
> > > Anything specific you need to know about the memory layout?
> > How sparse is it?  How few present pages can be there be in a worst-case
> > physical area?
> 
> Worst case that is already currently valid is that you can have 1 MB
> segments whereever you want in address space.
...
> Even though it's currently not possible to define memory segments above
> 1TB, this limit is likely to go away.

Go away, or get moved up?

ia64 today is designed to work with 50 bits of physical address space,
and 30 bit sections.  That's exactly the same scale that you're talking
about with 1MB sections and 1TB of physical space.  So, sparsemem
extreme should be perfectly fine for that case (that's explicitly what
it was designed for).

How much bigger than 1TB will it go?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
