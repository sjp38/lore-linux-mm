Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 7BBEA6B01B5
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 09:54:10 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o52Ds6qh006335
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 2 Jun 2010 22:54:07 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A30945DE79
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 22:54:06 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0BE7E45DE6E
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 22:54:06 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DFDA01DB803B
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 22:54:05 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 64A801DB8040
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 22:54:02 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm 13/18] oom: avoid race for oom killed tasks detaching mm prior to exit
In-Reply-To: <20100601204342.GC20732@redhat.com>
References: <alpine.DEB.2.00.1006011158230.32024@chino.kir.corp.google.com> <20100601204342.GC20732@redhat.com>
Message-Id: <20100602221633.F521.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Wed,  2 Jun 2010 22:54:01 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

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

Yep. That's exactly the reason why I would push his patch series at first.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
