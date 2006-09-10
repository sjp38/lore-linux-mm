Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate4.uk.ibm.com (8.13.8/8.13.8) with ESMTP id k8A7qnDv115240
	for <linux-mm@kvack.org>; Sun, 10 Sep 2006 07:52:49 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8A7sul31859598
	for <linux-mm@kvack.org>; Sun, 10 Sep 2006 08:54:58 +0100
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8A7qlrP017172
	for <linux-mm@kvack.org>; Sun, 10 Sep 2006 08:52:47 +0100
Date: Sun, 10 Sep 2006 09:51:54 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [patch 1/2] own header file for struct page.
Message-ID: <20060910075154.GA8354@osiris.ibm.com>
References: <20060908111716.GA6913@osiris.boeblingen.de.ibm.com> <Pine.LNX.4.64.0609092248400.6762@scrub.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0609092248400.6762@scrub.home>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roman Zippel <zippel@linux-m68k.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

> > In order to get of all these problems caused by macros it seems to
> > be a good idea to get rid of them and convert them to static inline
> > functions. Because of header file include order it's necessary to have a
> > seperate header file for the struct page definition.
> > 
> > Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> > Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
> > ---
> > 
> > Patches are against git tree as of today. Better ideas welcome of course.
> > 
> >  include/linux/mm.h   |   64 --------------------------------------------
> >  include/linux/page.h |   74 +++++++++++++++++++++++++++++++++++++++++++++++++++
> >  2 files changed, 75 insertions(+), 63 deletions(-)
> 
> To avoid the explosion in number of small header files each containing a 
> single definition, it would be better to generally split between the 
> definitions and implementations, so IMO mm_types.h with all the structures 
> and defines from mm.h would be better.

That could be done, but I wouldn't know where to start and where to end.
Moving simply all definitions to mm_types.h doesn't seem to be a good
solution. E.g. having something like "struct shrinker" in mm_types.h
seems to be rather pointless IMHO.
Maybe we can simply leave it by just taking the struct page definition
out for now?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
