Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5C4716B01B9
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 07:24:58 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5DBOsuU022656
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 13 Jun 2010 20:24:55 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id BCC8945DE6E
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8342545DE70
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 679111DB803A
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:54 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 23D1E1DB803B
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:54 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm 02/18] oom: sacrifice child with highest badness score for parent
In-Reply-To: <alpine.DEB.2.00.1006081140030.18848@chino.kir.corp.google.com>
References: <20100606175117.8721.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006081140030.18848@chino.kir.corp.google.com>
Message-Id: <20100613184150.617E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Sun, 13 Jun 2010 20:24:53 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > It mean we shouldn't assume parent and child have the same mems_allowed,
> > perhaps.
> > 
> 
> I'd be happy to have that in oom_kill_process() if you pass the
> enum oom_constraint and only do it for CONSTRAINT_CPUSET.  Please add a 
> followup patch to my latest patch series.

Please clarify.
Why do we need CONSTRAINT_CPUSET filter?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
