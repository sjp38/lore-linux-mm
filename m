Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id CABFE6B005D
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 19:46:52 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n5NNhEYF006426
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 19:43:14 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n5NNmKmS253324
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 19:48:20 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n5NNjw7o026261
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 19:45:58 -0400
Subject: Re: [PATCH] Hugepages should be accounted as unevictable pages.
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1245799709.24110.70.camel@alok-dev1>
References: <20090623093459.2204.A69D9226@jp.fujitsu.com>
	 <1245732411.18339.6.camel@alok-dev1>
	 <20090623135017.220D.A69D9226@jp.fujitsu.com>
	 <20090623141147.8f2cef18.kamezawa.hiroyu@jp.fujitsu.com>
	 <1245736441.18339.21.camel@alok-dev1>  <4A41481D.1060607@redhat.com>
	 <1245793331.24110.33.camel@alok-dev1>  <4A414F55.2040808@redhat.com>
	 <1245794811.24110.41.camel@alok-dev1>  <4A415D62.20109@redhat.com>
	 <1245799709.24110.70.camel@alok-dev1>
Content-Type: text/plain
Date: Tue, 23 Jun 2009 16:48:17 -0700
Message-Id: <1245800897.31856.28.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akataria@vmware.com
Cc: Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Mel Gorman <mel@csn.ul.ie>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2009-06-23 at 16:28 -0700, Alok Kataria wrote:
> Now regarding the patch that I posted, I need a way to get the
> hugepages count, there are 2 ways of doing this. 
> 1. exporting hugetlb_total_pages function for module usage.

Unfortunately, that won't even be enough.  That only accounts for the
default hstate.  There may be several hstate if the system supports
multiple large page sizes.  It's all exported in sysfs, but I don't see
any simple way (other than sys_open()) for a module to get at it.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
