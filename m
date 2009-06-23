Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D14166B0055
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 19:40:20 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e9.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n5NNT8up026186
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 19:29:08 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n5NNfXlM243306
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 19:41:33 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n5NNfWlN003284
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 19:41:33 -0400
Subject: Re: [PATCH] Hugepages should be accounted as unevictable pages.
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1245795823.24110.48.camel@alok-dev1>
References: <20090623093459.2204.A69D9226@jp.fujitsu.com>
	 <1245732411.18339.6.camel@alok-dev1>
	 <20090623135017.220D.A69D9226@jp.fujitsu.com>
	 <20090623141147.8f2cef18.kamezawa.hiroyu@jp.fujitsu.com>
	 <1245736441.18339.21.camel@alok-dev1>  <4A41481D.1060607@redhat.com>
	 <1245793331.24110.33.camel@alok-dev1> <1245795352.17685.31312.camel@nimitz>
	 <1245795823.24110.48.camel@alok-dev1>
Content-Type: text/plain
Date: Tue, 23 Jun 2009 16:41:30 -0700
Message-Id: <1245800490.31856.21.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akataria@vmware.com
Cc: Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Mel Gorman <mel@csn.ul.ie>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2009-06-23 at 15:23 -0700, Alok Kataria wrote:
> > Could you just teach the thing to which you are hinting that it also
> > needs to go look in sysfs for huge page counts?
> 
> :) yeah i could do that too...the point is that its a module and the
> function to get the hugepages count is not exported right now. I could
> very well add this as an exported symbol and use it from there, but
> there can be someone who doesn't want symbols to be unnecessarily
> exported if their is no in-tree modular usage of that symbol. 

Hmmm.  So what is the module doing?  The ol', "try to get as much memory
as I possibly can" game? :)

It sounds like you can get access to the vm statistics from existing
exported symbols, but the stats don't give you quite the info that you
need.  So, you're trying to change things that you *can* get access to.

We do export all this stuff to userspace.  We export all of the huge
page sizes and how many pages are reserved, used, and allocated in each,
plus the contentious Unevictable.  Could you just do this calculation in
userspace and pass it into the module with a modparam or sysfs file?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
