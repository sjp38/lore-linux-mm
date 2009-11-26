Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id D43056B00A0
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 21:35:52 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAQ2Zd0M006175
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 26 Nov 2009 11:35:39 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4425C45DE64
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 11:35:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C5CF45DE55
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 11:35:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D4185E78001
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 11:35:38 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 67A711DB803E
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 11:35:37 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: memcg: slab control
In-Reply-To: <alpine.DEB.2.00.0911251500150.20198@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.0911251500150.20198@chino.kir.corp.google.com>
Message-Id: <20091126113209.5A68.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 26 Nov 2009 11:35:36 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Suleiman Souhlal <suleiman@google.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi

> Hi,
> 
> I wanted to see what the current ideas are concerning kernel memory 
> accounting as it relates to the memory controller.  Eventually we'll want 
> the ability to restrict cgroups to a hard slab limit.  That'll require 
> accounting to map slab allocations back to user tasks so that we can 
> enforce a policy based on the cgroup's aggregated slab usage similiar to 
> how the memory controller currently does for user memory.
> 
> Is this currently being thought about within the memcg community?  We'd 
> like to start a discussion and get everybody's requirements and interests 
> on the table and then become actively involved in the development of such 
> a feature.

I don't think memory hard isolation is bad idea. however, slab restriction
is too strange. some device use slab frequently, another someone use get_free_pages()
directly. only slab restriction will not make expected result from admin view.

Probably, we need to implement generic memory reservation framework. it mihgt help
implemnt rt-task memory reservation and userland oom manager.

It is only my personal opinion...


Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
