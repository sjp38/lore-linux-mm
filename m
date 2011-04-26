Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2F5598D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 22:57:19 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 59F0B3EE0BC
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 11:57:14 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3EE3845DE5C
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 11:57:14 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2977D45DE5A
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 11:57:14 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1E014E08005
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 11:57:14 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DC740E08002
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 11:57:13 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] use oom_killer_disabled in all oom pathes
In-Reply-To: <20110426025429.GA11812@darkstar>
References: <20110426025429.GA11812@darkstar>
Message-Id: <20110426115902.F374.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 26 Apr 2011 11:57:13 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Young <hidave.darkstar@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> oom_killer_disable should be a global switch, also fit for oom paths
> other than __alloc_pages_slowpath 
> 
> Here add it to mem_cgroup_handle_oom and pagefault_out_of_memory as well.

Can you please explain more? Why should? Now oom_killer_disabled is used
only hibernation path. so, Why pagefault and memcg allocation will be happen?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
