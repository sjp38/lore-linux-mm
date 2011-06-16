Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id F18C56B0012
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 01:55:51 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id CFD7D3EE0BC
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 14:55:47 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id AC6B945DE68
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 14:55:47 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 901E945DE61
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 14:55:47 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 794C11DB8038
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 14:55:47 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1105F1DB803A
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 14:55:47 +0900 (JST)
Date: Thu, 16 Jun 2011 14:48:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: mmotm 2011-06-15-16-56 uploaded (mm/page_cgroup.c)
Message-Id: <20110616144848.e99c84d0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110615214917.a7dce8e6.randy.dunlap@oracle.com>
References: <201106160034.p5G0Y4dr028904@imap1.linux-foundation.org>
	<20110615214917.a7dce8e6.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Wed, 15 Jun 2011 21:49:17 -0700
Randy Dunlap <randy.dunlap@oracle.com> wrote:

> On Wed, 15 Jun 2011 16:56:49 -0700 akpm@linux-foundation.org wrote:
> 
> > The mm-of-the-moment snapshot 2011-06-15-16-56 has been uploaded to
> > 
> >    http://userweb.kernel.org/~akpm/mmotm/
> > 
> > and will soon be available at
> >    git://zen-kernel.org/kernel/mmotm.git
> > or
> >    git://git.cmpxchg.org/linux-mmotm.git
> > 
> > It contains the following patches against 3.0-rc3:
> 
> 
> (x86_64 build:)
> 
> mm/page_cgroup.c: In function 'page_cgroup_init':
> mm/page_cgroup.c:308: error: implicit declaration of function 'node_start_pfn'
> mm/page_cgroup.c:309: error: implicit declaration of function 'node_end_pfn'
> 
> 
> full kernel .config file is attached.
> 
Thank you. I'll dig today.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
