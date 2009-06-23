Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A9BE76B004F
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 17:54:22 -0400 (EDT)
Message-ID: <4A414F55.2040808@redhat.com>
Date: Tue, 23 Jun 2009 17:55:33 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Hugepages should be accounted as unevictable pages.
References: <20090623093459.2204.A69D9226@jp.fujitsu.com>	 <1245732411.18339.6.camel@alok-dev1>	 <20090623135017.220D.A69D9226@jp.fujitsu.com>	 <20090623141147.8f2cef18.kamezawa.hiroyu@jp.fujitsu.com>	 <1245736441.18339.21.camel@alok-dev1>  <4A41481D.1060607@redhat.com> <1245793331.24110.33.camel@alok-dev1>
In-Reply-To: <1245793331.24110.33.camel@alok-dev1>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akataria@vmware.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Alok Kataria wrote:
> On Tue, 2009-06-23 at 14:24 -0700, Rik van Riel wrote:

>> I can see something reasonable on both sides of this
>> particular debate.  However, even with this patch the
>> "unevictable" statistic does not reclaim the total
>> number of pages that are unevictable pages from a
>> zone, so I am not sure how it helps you achieve your
>> goal.
> 
> Yes but most of the other memory (page table and others) which is
> unevictable is actually static in nature.  IOW, the amount of this other
> kind of kernel unevictable pages can be actually interpolated from the
> amount of physical memory on the system. 

That would be a fair argument, if it were true.

Things like page tables and dentry/inode caches vary
according to the use case and are allocated as needed.
They are in no way "static in nature".

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
