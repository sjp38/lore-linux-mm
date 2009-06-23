Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id AEB4F6B004F
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 18:15:29 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n5NM9YIX009269
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 18:09:34 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n5NMFtEH251664
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 18:15:55 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n5NMFtQS017407
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 18:15:55 -0400
Subject: Re: [PATCH] Hugepages should be accounted as unevictable pages.
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1245793331.24110.33.camel@alok-dev1>
References: <20090623093459.2204.A69D9226@jp.fujitsu.com>
	 <1245732411.18339.6.camel@alok-dev1>
	 <20090623135017.220D.A69D9226@jp.fujitsu.com>
	 <20090623141147.8f2cef18.kamezawa.hiroyu@jp.fujitsu.com>
	 <1245736441.18339.21.camel@alok-dev1>  <4A41481D.1060607@redhat.com>
	 <1245793331.24110.33.camel@alok-dev1>
Content-Type: text/plain
Date: Tue, 23 Jun 2009 15:15:52 -0700
Message-Id: <1245795352.17685.31312.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akataria@vmware.com
Cc: Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Mel Gorman <mel@csn.ul.ie>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2009-06-23 at 14:42 -0700, Alok Kataria wrote:
> One thing that i forgot to mention earlier is that, I just need a way to
> provide a hint about the total locked memory  on the system and it
> doesn't need to be the exact number at that point in time.
> 
> Lee, due to this reason lazy culling of unevictable pages is fine too. 
> 
> Hugepages, similar to mlocked pages, are special because the user could
> specify how much memory it wants to reserve for this purpose. So that
> needs to be taken into consideration i.e it cannot be calculated in some
> way. 

Could you just teach the thing to which you are hinting that it also
needs to go look in sysfs for huge page counts?  Or, is there a
requirement that it come out of a single meminfo field?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
