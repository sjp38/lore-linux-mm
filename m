Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id LAA03847
	for <linux-mm@kvack.org>; Wed, 27 Nov 2002 11:36:07 -0800 (PST)
Message-ID: <3DE51EA7.5C971354@digeo.com>
Date: Wed, 27 Nov 2002 11:36:07 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [PATCH] page walker bugfix (was: 2.5.49-mm2)
References: <3DE48C4A.98979F0C@digeo.com> <20021127171017.H5263@nightmaster.csn.tu-chemnitz.de>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Ingo Oeser wrote:
> 
> Hi Andrew,
> hi list readers,
> 
> On Wed, Nov 27, 2002 at 01:11:38AM -0800, Andrew Morton wrote:
> > .. Some code from Ingo Oeser to start using the expanded and cleaned up
> >   user pagetable walker code.  This affects the st and sg drivers; I'm
> >   not sure of the testing status of this?
> 
> The testing status is: None, but it compiles.
> 
> The sg-driver maintainer has already said he does some testing
> and the author of the previous code in st.c was positive about
> using these features. That's why I've choosen these as my "victims".

Yes, Doug Gilbert will help us out here.

> I also found a locking bug in walk_user_pages() in case of OOM or
> SIGBUS. Fixed by the attached patch.
> 

Thanks.

We'll need to be concentrating on the shared pagetable code for
a while, and your patch overlaps with that.  So I've swapped the
applying order (you come second) and I'll probably break your
stuff out separately for a while so Dave can generate clean patches.

When mm3 emerges could you please check mm/mmap.c around here:

        vma = NULL; /* needed for out-label */

I may have misplaced that one...
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
