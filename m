Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id QAA03069
	for <linux-mm@kvack.org>; Sat, 28 Dec 2002 16:53:48 -0800 (PST)
Message-ID: <3E0E4795.8CF39BEF@digeo.com>
Date: Sat, 28 Dec 2002 16:53:41 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: handling pte_chain_alloc() failures
References: <3E0CEA3F.35B3044@digeo.com> <23300000.1041119970@[10.1.1.5]>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dave McCracken wrote:
> 
> --On Friday, December 27, 2002 16:03:11 -0800 Andrew Morton
> <akpm@digeo.com> wrote:
> 
> > Dave, could I ask you to check the locking changes carefully?  Some
> > of them are fairly nasty.  Thanks.
> 
> The only thing I specifically see is related to the pte_page_lock.  In
> places where ptepage is derived from *pmd, the contents of *pmd can change
> if another thread unshares that pte page on a fault.  There should be a
> line like:
> 
>         ptepage = pmd_page(*pmd);
> 
> in the places where it reacquires the pte_page_lock.
> 
> I'll study it some more, but that stands out.
> 

OK, thanks.  I just uploaded -mm2.  Probably the easiest way to review
my manglings is to just grep for page_add_rmap, and eyeball each site.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
