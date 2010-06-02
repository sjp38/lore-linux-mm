Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 5BA026B01B0
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 20:32:44 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o520Wfhe018252
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 2 Jun 2010 09:32:41 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B203445DE54
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 09:32:41 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4235945DE62
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 09:32:41 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E5C20E08020
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 09:32:40 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 99FC1E0800A
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 09:32:37 +0900 (JST)
Date: Wed, 2 Jun 2010 09:28:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch -mm 13/18] oom: avoid race for oom killed tasks
 detaching mm prior to exit
Message-Id: <20100602092819.58579806.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100601204342.GC20732@redhat.com>
References: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1006010016460.29202@chino.kir.corp.google.com>
	<20100601164026.2472.A69D9226@jp.fujitsu.com>
	<alpine.DEB.2.00.1006011158230.32024@chino.kir.corp.google.com>
	<20100601204342.GC20732@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 1 Jun 2010 22:43:42 +0200
Oleg Nesterov <oleg@redhat.com> wrote:

> On 06/01, David Rientjes wrote:
> >
> > No, it applies to mmotm-2010-05-21-16-05 as all of these patches do. I
> > know you've pushed Oleg's patches
> 
> (plus other fixes)
> 
> > but they are also included here so no
> > respin is necessary unless they are merged first (and I think that should
> > only happen if Andrew considers them to be rc material).
> 
> Well, I disagree.
> 
> I think it is always better to push the simple bugfixes first, then
> change/improve the logic.
> 
yes..yes...I hope David finish easy-to-be-merged ones and go to new stage.
IOW, please reduce size of patches sent at once.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
