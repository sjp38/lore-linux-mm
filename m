Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j33J6IM8027124
	for <linux-mm@kvack.org>; Sun, 3 Apr 2005 15:06:18 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j33J6FU3081916
	for <linux-mm@kvack.org>; Sun, 3 Apr 2005 15:06:18 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j33J6ExS032098
	for <linux-mm@kvack.org>; Sun, 3 Apr 2005 15:06:14 -0400
Subject: Re: AIM9 slowdowns between 2.6.11 and 2.6.12-rc1
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.58.0504031532570.25594@skynet>
References: <Pine.LNX.4.58.0504031532570.25594@skynet>
Content-Type: text/plain
Date: Sun, 03 Apr 2005 12:06:10 -0700
Message-Id: <1112555170.7189.34.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sun, 2005-04-03 at 15:37 +0100, Mel Gorman wrote:
> While testing the page placement policy patches on 2.6.12-rc1, I noticed
> that aim9 is showing significant slowdowns on page allocation-related
> tests. An excerpt of the results is at the end of this mail but it shows
> that page_test is allocating 18000 less pages.
> 
> I did not check who has been recently changing the buddy allocator but
> they might want to run a benchmark or two to make sure this is not
> something specific to my setup.

Can you get some kernel profiles to see what, exactly, is causing the
decreased performance?  Also, what kind of system do you have?  Does
backing this out help?  If not, can you test some BK snapshots to see
when this started occurring?  

http://linus.bkbits.net:8080/linux-2.5/cset@422de02c1628MP_noKSum9sGlTaC-Q

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
