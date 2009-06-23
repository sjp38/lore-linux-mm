Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 7DC416B004F
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 18:54:19 -0400 (EDT)
Message-ID: <4A415D62.20109@redhat.com>
Date: Tue, 23 Jun 2009 18:55:30 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Hugepages should be accounted as unevictable pages.
References: <20090623093459.2204.A69D9226@jp.fujitsu.com>	 <1245732411.18339.6.camel@alok-dev1>	 <20090623135017.220D.A69D9226@jp.fujitsu.com>	 <20090623141147.8f2cef18.kamezawa.hiroyu@jp.fujitsu.com>	 <1245736441.18339.21.camel@alok-dev1>  <4A41481D.1060607@redhat.com>	 <1245793331.24110.33.camel@alok-dev1>  <4A414F55.2040808@redhat.com> <1245794811.24110.41.camel@alok-dev1>
In-Reply-To: <1245794811.24110.41.camel@alok-dev1>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akataria@vmware.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Alok Kataria wrote:
> On Tue, 2009-06-23 at 14:55 -0700, Rik van Riel wrote:
>> Alok Kataria wrote:
>>> On Tue, 2009-06-23 at 14:24 -0700, Rik van Riel wrote:

>> Things like page tables and dentry/inode caches vary
>> according to the use case and are allocated as needed.
>> They are in no way "static in nature".
> 
> Maybe static was the wrong word to use here. 
> What i meant was that you could always calculate the *maximum* amount of
> memory that is going to be used by page table and can also determine the
> % of memory that will be used by slab caches.

My point is that you cannot do that.

We have seen systems with 30% of physical memory in
page tables, as well as systems with a similar amount
of memory in the slab cache.

Yes, these were running legitimate workloads.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
