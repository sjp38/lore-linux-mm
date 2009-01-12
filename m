Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 457896B004F
	for <linux-mm@kvack.org>; Mon, 12 Jan 2009 02:29:25 -0500 (EST)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id n0C7e22m220756
	for <linux-mm@kvack.org>; Mon, 12 Jan 2009 18:40:02 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n0C7Mbu02764842
	for <linux-mm@kvack.org>; Mon, 12 Jan 2009 18:22:38 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n0C7LbNc009969
	for <linux-mm@kvack.org>; Mon, 12 Jan 2009 18:21:38 +1100
Date: Mon, 12 Jan 2009 12:51:32 +0530
From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Subject: Re: [BUG] 2.6.28-git-4 - powerpc - kernel expection 'c01 at
	.kernel_thread'
Message-ID: <20090112072132.GA8409@linux.vnet.ibm.com>
Reply-To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
References: <20090102125752.GA5743@linux.vnet.ibm.com> <200901110108.20848.rjw@sisk.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <200901110108.20848.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, linux-mm@kvack.org, sfr@canb.auug.org.au, benh@kernel.crashing.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

* Rafael J. Wysocki <rjw@sisk.pl> [2009-01-11 01:08:19]:

> On Friday 02 January 2009, Kamalesh Babulal wrote:
> > Hi,
> > 
> > 	2.6.28-git4 kernel drops to xmon with kernel expection. Similar kernel
> > expection was seen next-20081230 and next-20081231 and was reported 
> > earlier at http://lkml.org/lkml/2008/12/31/157
> 
> Is this a regression from 2.6.27?
> 
> Rafael
>

This is not a regression from 2.6.27, this expection was first seen 
next-20081230 patches and then was introduced into 2.6.28-git4 and is 
reproducible with 2.6.28-rc1 kernel.

-- 
Thanks & Regards,
Kamalesh Babulal,
Linux Technology Center,
IBM, ISTL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
