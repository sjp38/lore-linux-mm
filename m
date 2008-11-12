Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAC6XrkG024536
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 12 Nov 2008 15:33:53 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id A42B045DE53
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 15:33:52 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7727B45DE4F
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 15:33:52 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B3CBE08003
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 15:33:52 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id C9A7B1DB803B
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 15:33:51 +0900 (JST)
Date: Wed, 12 Nov 2008 15:33:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][mm] [PATCH 3/4] Memory cgroup hierarchical reclaim (v3)
Message-Id: <20081112153314.a7162192.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <491A7637.3050402@linux.vnet.ibm.com>
References: <20081111123314.6566.54133.sendpatchset@balbir-laptop>
	<20081111123417.6566.52629.sendpatchset@balbir-laptop>
	<20081112140236.46448b47.kamezawa.hiroyu@jp.fujitsu.com>
	<491A6E71.5010307@linux.vnet.ibm.com>
	<20081112150126.46ac6042.kamezawa.hiroyu@jp.fujitsu.com>
	<491A7345.4090500@linux.vnet.ibm.com>
	<20081112151233.0ec8dc44.kamezawa.hiroyu@jp.fujitsu.com>
	<491A7637.3050402@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 12 Nov 2008 11:52:47 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > On Wed, 12 Nov 2008 11:40:13 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> >> I think of it as easy to update - as in the modularity, you can plug out
> >> hierarchical reclaim easily and implement your own hierarchical reclaim.
> >>
> > When I do so, I'll rewrite all, again.
> > 
> 
> I don't intend to ask you to rewrite it, rewrite all, I meant you as in a
> generic person. With hierarchy we will need weighted reclaim, which I'll add in
> later.
> 
> >>> Can you make this code iterative rather than recursive ?
> >>>
> >>> I don't like this kind of recursive call with complexed lock/unlock.
> >> I tried an iterative version, which ended up looking very ugly. I think the
> >> recursive version is easier to understand. What we do is a DFS walk - pretty
> >> standard algorithm.
> >>
> > But recursive one is not good for search-and-try algorithm.
> 
> OK, I'll post the iterative algorithm, but it is going to be dirty :)
> 
Ah, thanks. I think maybe you're right that ittrative one is dirty.
I want to compare before going further. 
Thank you for your patience.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
