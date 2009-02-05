Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2DB806B003D
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 20:16:17 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n151GE5I028423
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 5 Feb 2009 10:16:14 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1EB312AEA81
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 10:16:14 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id F02B51EF081
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 10:16:13 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D7A0F1DB8043
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 10:16:13 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8FA381DB8040
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 10:16:13 +0900 (JST)
Date: Thu, 5 Feb 2009 10:15:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] release mmap_sem before starting migration (Was
 Re: Need to take mmap_sem lock in move_pages.
Message-Id: <20090205101503.b1fd7df6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.1.10.0902041037150.19633@qirst.com>
References: <28631E6913C8074E95A698E8AC93D091B21561@caexch1.virident.info>
	<20090204183600.f41e8b7e.kamezawa.hiroyu@jp.fujitsu.com>
	<20090204184028.09a4bbae.kamezawa.hiroyu@jp.fujitsu.com>
	<20090204185501.837ff5d6.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.1.10.0902041037150.19633@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Swamy Gowda <swamy@virident.com>, linux-kernel@vger.kernel.org, Brice.Goglin@inria.fr, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 4 Feb 2009 10:39:19 -0500 (EST)
Christoph Lameter <cl@linux-foundation.org> wrote:

> On Wed, 4 Feb 2009, KAMEZAWA Hiroyuki wrote:
> 
> > mmap_sem can be released after page table walk ends.
> 
> No. read lock on mmap_sem must be held since the migrate functions
> manipulate page table entries. Concurrent large scale changes to the page
> tables (splitting vmas, remapping etc) must not be possible.
> 
Just for clarification:

1. changes in page table is not problem from the viewpoint of kernel.
   (means no panic, no leak,...)
2. But this loses "atomic" aspect of migration and will allow unexpected
   behaviors.
   (means the page-mapping status after sys_move may not be what user expects.)


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
