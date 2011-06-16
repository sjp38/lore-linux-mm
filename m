Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 79F446B0012
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 04:35:20 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 44B093EE0C1
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 17:35:15 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B61645DE6A
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 17:35:15 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 13E8645DE61
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 17:35:15 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 068871DB8040
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 17:35:15 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B9D281DB802C
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 17:35:14 +0900 (JST)
Date: Thu, 16 Jun 2011 17:28:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: mmotm 2011-06-15-16-56 uploaded (mm/page_cgroup.c)
Message-Id: <20110616172819.1e2d325c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110615214917.a7dce8e6.randy.dunlap@oracle.com>
References: <201106160034.p5G0Y4dr028904@imap1.linux-foundation.org>
	<20110615214917.a7dce8e6.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, mgorman@suse.de

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

Bug fix is here. Added CC to Mel to get review.
==
