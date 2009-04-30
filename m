Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 21FB36B004D
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 04:28:34 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3U8SxWV021759
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 30 Apr 2009 17:28:59 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C4ED745DE53
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 17:28:58 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E58B45DD72
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 17:28:58 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5AA0C1DB803F
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 17:28:58 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 10DED1DB8038
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 17:28:58 +0900 (JST)
Date: Thu, 30 Apr 2009 17:27:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH mmotm] memcg: fix mem_cgroup_update_mapped_file_stat
 oops
Message-Id: <20090430172727.82b1e9d2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090430045240.GA4430@balbir.in.ibm.com>
References: <Pine.LNX.4.64.0904292209550.30874@blonde.anvils>
	<20090430090646.a1443096.kamezawa.hiroyu@jp.fujitsu.com>
	<20090430045240.GA4430@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 30 Apr 2009 10:22:40 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-30 09:06:46]:
> 
> > On Wed, 29 Apr 2009 22:13:33 +0100 (BST)
> > Hugh Dickins <hugh@veritas.com> wrote:
> > 
> > > CONFIG_SPARSEMEM=y CONFIG_CGROUP_MEM_RES_CTLR=y cgroup_disable=memory
> > > bootup is oopsing in mem_cgroup_update_mapped_file_stat().  !SPARSEMEM
> > > is fine because its lookup_page_cgroup() contains an explicit check for
> > > NULL node_page_cgroup, but the SPARSEMEM version was missing a check for
> > > NULL section->page_cgroup.
> > > 
> > Ouch, it's curious this bug alive now.. thank you.
> > 
> > Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > I think this patch itself is sane but.. Balbir, could you see "caller" ?
> > It seems strange.
> 
> Ideally we need to have a disabled check in
> mem_cgroup_update_mapped_file_stat(), but it seems as if this fix is
> better and fixes a larger scenario and the root cause of
> lookup_page_cgroup() OOPSing. It would not hurt to check for
> mem_cgroup_disabled() though, but too many checks might spoil the
> party for frequent operations.
> 
> Kame, do you mean you wanted me to check if I am using
> lookup_page_cgroup() correctly?
> 
Yes. I have no complaints to this patch but just curious.
Anyway thanks.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
