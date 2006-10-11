Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate5.uk.ibm.com (8.13.8/8.13.8) with ESMTP id k9BEmLCI208108
	for <linux-mm@kvack.org>; Wed, 11 Oct 2006 14:48:21 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k9BEomsr1863828
	for <linux-mm@kvack.org>; Wed, 11 Oct 2006 15:50:48 +0100
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k9BEmLvM026773
	for <linux-mm@kvack.org>; Wed, 11 Oct 2006 15:48:21 +0100
Subject: Re: [patch 3/3] mm: add arch_alloc_page
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
In-Reply-To: <452856E4.60705@yahoo.com.au>
References: <20061007105758.14024.70048.sendpatchset@linux.site>
	 <20061007105824.14024.85405.sendpatchset@linux.site>
	 <20061007134345.0fa1d250.akpm@osdl.org>  <452856E4.60705@yahoo.com.au>
Content-Type: text/plain
Date: Wed, 11 Oct 2006 16:48:24 +0200
Message-Id: <1160578104.634.2.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sun, 2006-10-08 at 11:39 +1000, Nick Piggin wrote:
> >On Sat,  7 Oct 2006 15:06:04 +0200 (CEST)
> >Nick Piggin <npiggin@suse.de> wrote:
> >
> >
> >>Add an arch_alloc_page to match arch_free_page.
> >>
> >
> >umm.. why?
> >
> 
> I had a future patch to more kernel_map_pages into it, but couldn't
> decide if that's a generic kernel feature that is only implemented in
> 2 architectures, or an architecture speicifc feature. So I left it out.
> 
> But at least Martin wanted a hook here for his volatile pages patches,
> so I thought I'd submit this patch anyway.

With Nicks patch I can use arch_alloc_page instead of page_set_stable,
but I can still not use arch_free_page instead of page_set_unused
because it is done before the check for reserved pages. If reserved
pages go away or the arch_free_page call would get moved after the check
I could replace page_set_unused as well. So with Nicks patch we are only
halfway there..

-- 
blue skies,
  Martin.

Martin Schwidefsky
Linux for zSeries Development & Services
IBM Deutschland Entwicklung GmbH

"Reality continues to ruin my life." - Calvin.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
