Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 530476B004F
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 18:19:23 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n5NMG6o1026753
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 16:16:06 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n5NMJvW1252556
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 16:19:57 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n5NMJvmG007860
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 16:19:57 -0600
Subject: Re: [PATCH] Hugepages should be accounted as unevictable pages.
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1245794811.24110.41.camel@alok-dev1>
References: <20090623093459.2204.A69D9226@jp.fujitsu.com>
	 <1245732411.18339.6.camel@alok-dev1>
	 <20090623135017.220D.A69D9226@jp.fujitsu.com>
	 <20090623141147.8f2cef18.kamezawa.hiroyu@jp.fujitsu.com>
	 <1245736441.18339.21.camel@alok-dev1>  <4A41481D.1060607@redhat.com>
	 <1245793331.24110.33.camel@alok-dev1>  <4A414F55.2040808@redhat.com>
	 <1245794811.24110.41.camel@alok-dev1>
Content-Type: text/plain
Date: Tue, 23 Jun 2009 15:19:55 -0700
Message-Id: <1245795595.17685.31320.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akataria@vmware.com
Cc: Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Mel Gorman <mel@csn.ul.ie>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2009-06-23 at 15:06 -0700, Alok Kataria wrote:
> What i meant was that you could always calculate the *maximum* amount of
> memory that is going to be used by page table and can also determine the
> % of memory that will be used by slab caches. 

I'm not really sure what you mean by this.  I actually just wrote a
little userspace program the other day that fills virtually all of ram
in with pagetables.  There's no real upper bound on them, unless you're
restricting the amount of mapped space that all the userspace processes
determine.  In the same way, the right usage pattern can give virtually
all the RAM in the system and put it in a single or set of slabs.  It's
probably evictable most of the time, but sometimes large amounts can be
pinned.

> So that ways you should be statically able to tell that no more than 'X'
> amount of memory is going to be locked here.
> Will again like to stress that "X" is not the exact amount that is
> locked here but the one which can be. 
> 
> OTOH, for hugepages and mlocked pages you need to read the exact counts
> as this can change according to user selection. 

I'm a bit lost.  Could we take a step back here and talk about what
you're trying to do in the first place?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
