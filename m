Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 52A696B01DE
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 07:41:57 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o58BftmJ007957
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 8 Jun 2010 20:41:55 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0AC1845DE57
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:41:55 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id CEF3F45DE52
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:41:54 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9FBE0E08003
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:41:54 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 517751DB8040
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:41:51 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm 11/18] oom: avoid oom killer for lowmem allocations
In-Reply-To: <alpine.DEB.2.00.1006010015460.29202@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com> <alpine.DEB.2.00.1006010015460.29202@chino.kir.corp.google.com>
Message-Id: <20100606184014.8727.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Tue,  8 Jun 2010 20:41:50 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Previously, the heuristic provided some protection for those tasks with
> CAP_SYS_RAWIO, but this is no longer necessary since we will not be
> killing tasks for the purposes of ISA allocations.

Seems incorrect. CAP_SYS_RAWIO tasks usually both use GFP_KERNEL and GFP_DMA.
Even if last allocation is GFP_KERNEL, it doesn't provide any gurantee the
process doesn't have any in flight I/O.

Then, we can't remove for RAWIO protection from oom heuristics. but the code
itself seems ok though.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
