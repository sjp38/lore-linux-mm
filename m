Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m42HFjkf010684
	for <linux-mm@kvack.org>; Fri, 2 May 2008 13:15:45 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m42HFjSN144204
	for <linux-mm@kvack.org>; Fri, 2 May 2008 11:15:45 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m42HFio3022759
	for <linux-mm@kvack.org>; Fri, 2 May 2008 11:15:45 -0600
Subject: Re: [RFC][PATCH 2/2] Add huge page backed stack support
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1209693109.8483.23.camel@grover.beaverton.ibm.com>
References: <1209693109.8483.23.camel@grover.beaverton.ibm.com>
Content-Type: text/plain
Date: Fri, 02 May 2008 10:15:42 -0700
Message-Id: <1209748542.7763.39.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ebmunson@us.ibm.com
Cc: linux-mm@kvack.org, nacc <nacc@linux.vnet.ibm.com>, mel@csn.ul.ie, andyw <andyw@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-05-01 at 18:51 -0700, Eric B Munson wrote
> The GROWSUP and GROWSDOWN VM flags are turned off because a hugetlb backed
> vma is not resizable, so it will be appropriately sized when created.  When
> a process exceeds stack size it recieves a segfault exactly as it would if it
> exceeded the ulimit.

This one is *really* subtle.  The segfault might behave like breaking a
ulimit.  But, unlike a ulimit, you can't really work around this
particular limitation very easily.

This will really suck for anyone that tries to use 64k huge pages on
powerpc, right?

Are you actually looking to get this included, or are you just trying to
play with this?  It is useful as a toy as-is, but I think you should
look at fixing stack growing before it gets merged anywhere.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
