Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5B38UrE008324
	for <linux-mm@kvack.org>; Tue, 10 Jun 2008 23:08:30 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5B3CiOf174054
	for <linux-mm@kvack.org>; Tue, 10 Jun 2008 21:12:44 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5B3CiWQ007665
	for <linux-mm@kvack.org>; Tue, 10 Jun 2008 21:12:44 -0600
Subject: Re: [RFC:PATCH 06/06] powerpc: Don't clear _PAGE_COHERENT when
	_PAGE_SAO is set
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
In-Reply-To: <484EFF86.1030709@ru.mvista.com>
References: <20080610220055.10257.84465.sendpatchset@norville.austin.ibm.com>
	 <20080610220129.10257.69024.sendpatchset@norville.austin.ibm.com>
	 <484EFF86.1030709@ru.mvista.com>
Content-Type: text/plain
Date: Tue, 10 Jun 2008 22:12:42 -0500
Message-Id: <1213153962.6714.0.camel@norville.austin.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Cc: linuxppc-dev list <Linuxppc-dev@ozlabs.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-06-11 at 02:26 +0400, Sergei Shtylyov wrote:
> Hello.
> 
> Dave Kleikamp wrote:
> > powerpc: Don't clear _PAGE_COHERENT when _PAGE_SAO is set
> >
> > This is a placeholder.  Benh tells me that he will come up with a better fix.
> >
> > Signed-off-by: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
> > ---
> >
> >  arch/powerpc/platforms/pseries/lpar.c |    3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> >
> > diff -Nurp linux005/arch/powerpc/platforms/pseries/lpar.c linux006/arch/powerpc/platforms/pseries/lpar.c
> > --- linux005/arch/powerpc/platforms/pseries/lpar.c	2008-06-05 10:07:34.000000000 -0500
> > +++ linux006/arch/powerpc/platforms/pseries/lpar.c	2008-06-10 16:48:59.000000000 -0500
> > @@ -305,7 +305,8 @@ static long pSeries_lpar_hpte_insert(uns
> >  	flags = 0;
> >  
> >  	/* Make pHyp happy */
> > -	if (rflags & (_PAGE_GUARDED|_PAGE_NO_CACHE))
> > +	if ((rflags & _PAGE_GUARDED) ||
> > +	    ((rflags & _PAGE_NO_CACHE) & !(rflags & _PAGE_WRITETHRU)))
> >   
>    I don't think you really meant bitwise AND here. I suppose the second 
> expression just will never be true.

You're right.  That should be &&.  Thanks.

> WBR, Sergei
> 
> 
-- 
David Kleikamp
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
