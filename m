Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 5A1236B0062
	for <linux-mm@kvack.org>; Mon, 20 Jul 2009 20:05:35 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6L05ZGG010296
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 21 Jul 2009 09:05:35 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id BC19A45DE4E
	for <linux-mm@kvack.org>; Tue, 21 Jul 2009 09:05:33 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id DC59C45DE4F
	for <linux-mm@kvack.org>; Tue, 21 Jul 2009 09:05:32 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id DCC731DB803C
	for <linux-mm@kvack.org>; Tue, 21 Jul 2009 09:05:31 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 402CBE18010
	for <linux-mm@kvack.org>; Tue, 21 Jul 2009 09:05:30 +0900 (JST)
Date: Tue, 21 Jul 2009 09:03:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 0/5] Memory controller soft limit patches (v9)
Message-Id: <20090721090317.786141e9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090720154859.GI24157@balbir.in.ibm.com>
References: <20090710125950.5610.99139.sendpatchset@balbir-laptop>
	<20090720154859.GI24157@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 20 Jul 2009 21:18:59 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * Balbir Singh <balbir@linux.vnet.ibm.com> [2009-07-10 18:29:50]:
> 
> > 
> > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > 
> > New Feature: Soft limits for memory resource controller.
> > 
> > Here is v9 of the new soft limit implementation. Soft limits is a new feature
> > for the memory resource controller, something similar has existed in the
> > group scheduler in the form of shares. The CPU controllers interpretation
> > of shares is very different though. 
> > 
> > Soft limits are the most useful feature to have for environments where
> > the administrator wants to overcommit the system, such that only on memory
> > contention do the limits become active. The current soft limits implementation
> > provides a soft_limit_in_bytes interface for the memory controller and not
> > for memory+swap controller. The implementation maintains an RB-Tree of groups
> > that exceed their soft limit and starts reclaiming from the group that
> > exceeds this limit by the maximum amount.
> > 
> > v9 attempts to address several review comments for v8 by Kamezawa, including
> > moving over to an event based approach for soft limit rb tree management,
> > simplification of data structure names and many others. Comments not
> > addressed have been answered via email or I've added comments in the code.
> > 
> > TODOs
> > 
> > 1. The current implementation maintains the delta from the soft limit
> >    and pushes back groups to their soft limits, a ratio of delta/soft_limit
> >    might be more useful
> > 
> 
> 
> Hi, Andrew,
> 
> Could you please pick up this patchset for testing in -mm, both
> Kamezawa-San and Kosaki-San have looked at the patches. I think they
> are ready for testing in mmotm.
> 
ok, plz go. But please consider to rewrite res_coutner related part in more
generic style, allowing mulitple threshold & callbacks without overheads.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
