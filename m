Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6103E6B004F
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 23:25:01 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5N3PjAS032429
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 23 Jun 2009 12:25:45 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 59C7A45DD7D
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 12:25:45 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A8FD45DD7B
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 12:25:45 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C67F1DB8037
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 12:25:45 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BF8B51DB8040
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 12:25:44 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] Hugepages should be accounted as unevictable pages.
In-Reply-To: <1245705941.26649.19.camel@alok-dev1>
References: <1245705941.26649.19.camel@alok-dev1>
Message-Id: <20090623093459.2204.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 23 Jun 2009 12:25:44 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: akataria@vmware.com
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Looking at the output of /proc/meminfo, a user might get confused in thinking
> that there are zero unevictable pages, though, in reality their can be
> hugepages which are inherently unevictable. 
> 
> Though hugepages are not handled by the unevictable lru framework, they are
> infact unevictable in nature and global statistics counter should reflect that. 
> 
> For instance, I have allocated 20 huge pages on my system, meminfo shows this 
> 
> Unevictable:           0 kB
> Mlocked:               0 kB
> HugePages_Total:      20
> HugePages_Free:       20
> HugePages_Rsvd:        0
> HugePages_Surp:        0
> 
> After the patch:
> 
> Unevictable:       81920 kB
> Mlocked:               0 kB
> HugePages_Total:      20
> HugePages_Free:       20
> HugePages_Rsvd:        0
> HugePages_Surp:        0

At first, We should clarify the spec of unevictable.
Currently, Unevictable field mean the number of pages in unevictable-lru
and hugepage never insert any lru.

I think this patch will change this rule.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
