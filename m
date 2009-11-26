Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 77CC36B009B
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 20:20:00 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAQ1Jq4Q019093
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 26 Nov 2009 10:19:52 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8241745DE6F
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 10:19:52 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 602AF45DE60
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 10:19:52 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3BFD51DB803B
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 10:19:52 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E2D271DB8037
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 10:19:51 +0900 (JST)
Date: Thu, 26 Nov 2009 10:17:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: memcg: slab control
Message-Id: <20091126101704.879a1b15.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.0911251500150.20198@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.0911251500150.20198@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Suleiman Souhlal <suleiman@google.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 25 Nov 2009 15:08:00 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

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
> 

BTW, how much percent of pages are used for slab in Google system ?
Because memory size is going bigger and bigger, ratio of slab usage is going
smaller, I think.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
