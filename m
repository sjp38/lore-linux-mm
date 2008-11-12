Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAC6DDPf002734
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 12 Nov 2008 15:13:13 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E7CA945DE4C
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 15:13:12 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C24C945DE3D
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 15:13:12 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id AA0D11DB803F
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 15:13:12 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C6711DB8038
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 15:13:12 +0900 (JST)
Date: Wed, 12 Nov 2008 15:12:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][mm] [PATCH 3/4] Memory cgroup hierarchical reclaim (v3)
Message-Id: <20081112151233.0ec8dc44.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <491A7345.4090500@linux.vnet.ibm.com>
References: <20081111123314.6566.54133.sendpatchset@balbir-laptop>
	<20081111123417.6566.52629.sendpatchset@balbir-laptop>
	<20081112140236.46448b47.kamezawa.hiroyu@jp.fujitsu.com>
	<491A6E71.5010307@linux.vnet.ibm.com>
	<20081112150126.46ac6042.kamezawa.hiroyu@jp.fujitsu.com>
	<491A7345.4090500@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 12 Nov 2008 11:40:13 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> I think of it as easy to update - as in the modularity, you can plug out
> hierarchical reclaim easily and implement your own hierarchical reclaim.
> 
When I do so, I'll rewrite all, again.

> > Can you make this code iterative rather than recursive ?
> > 
> > I don't like this kind of recursive call with complexed lock/unlock.
> 
> I tried an iterative version, which ended up looking very ugly. I think the
> recursive version is easier to understand. What we do is a DFS walk - pretty
> standard algorithm.
> 
But recursive one is not good for search-and-try algorithm.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
