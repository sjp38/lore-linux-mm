Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mA67Uw9g016448
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 6 Nov 2008 16:30:58 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D2EF45DD85
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 16:30:58 +0900 (JST)
Received: from s7.gw.fujitsu.co.jp (s7.gw.fujitsu.co.jp [10.0.50.97])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DC4DD45DD80
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 16:30:57 +0900 (JST)
Received: from s7.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id BC5221DB8041
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 16:30:57 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id 646EC1DB8037
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 16:30:57 +0900 (JST)
Date: Thu, 6 Nov 2008 16:30:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [mm] [PATCH 4/4] Memory cgroup hierarchy feature selector
Message-Id: <20081106163021.93f3cbe2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4912951D.60301@linux.vnet.ibm.com>
References: <20081101184812.2575.68112.sendpatchset@balbir-laptop>
	<20081101184902.2575.11443.sendpatchset@balbir-laptop>
	<20081102143817.99edca6d.kamezawa.hiroyu@jp.fujitsu.com>
	<490D42C7.4000301@linux.vnet.ibm.com>
	<20081102152412.2af29a1b.kamezawa.hiroyu@jp.fujitsu.com>
	<4912951D.60301@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 06 Nov 2008 12:26:29 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > On Sun, 02 Nov 2008 11:33:51 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> >> KAMEZAWA Hiroyuki wrote:
> >>> On Sun, 02 Nov 2008 00:19:02 +0530
> >>> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> >>>
> >>>> Don't enable multiple hierarchy support by default. This patch introduces
> >>>> a features element that can be set to enable the nested depth hierarchy
> >>>> feature. This feature can only be enabled when there is just one cgroup
> >>>> (the root cgroup).
> >>>>
> >>> Why the flag is for the whole system ?
> >>> flag-per-subtree is of no use ?
> >> Flag per subtree might not be useful, since we charge all the way up to root,
> > Ah, what I said is "How about enabling/disabling hierarhcy support per subtree ?"
> > Sorry for bad text.
> > 
> > like this.
> >   - you can set hierarchy mode of a cgroup turned on/off when...
> >     * you don't have any tasks under it && it doesn't have any child cgroup.
> 
> I see.. the presence of tasks don't matter, since the root cgroup will always
> have tasks. Presence of child groups does matter.
> 
yes. you're right.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
