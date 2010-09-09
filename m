Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 7E1BB6B007B
	for <linux-mm@kvack.org>; Thu,  9 Sep 2010 00:50:17 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o894oEQp020764
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 9 Sep 2010 13:50:15 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B0C445DE53
	for <linux-mm@kvack.org>; Thu,  9 Sep 2010 13:50:14 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 44FF545DE4E
	for <linux-mm@kvack.org>; Thu,  9 Sep 2010 13:50:14 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D6EECE08004
	for <linux-mm@kvack.org>; Thu,  9 Sep 2010 13:50:13 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1E3BB1DB803F
	for <linux-mm@kvack.org>; Thu,  9 Sep 2010 13:50:13 +0900 (JST)
Date: Thu, 9 Sep 2010 13:44:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/5] memcg: towards I/O aware memcg v7.
Message-Id: <20100909134459.361a0f61.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100901153951.bc82c021.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100901153951.bc82c021.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, gthelen@google.com, Munehiro Ikeda <m-ikeda@ds.jp.nec.com>, menage@google.com, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 1 Sep 2010 15:39:51 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> 
> Major changes from v6 is
>  a) added documentation about CSS ID.
>  b) fixed typos and bugs.
>  c) refleshed some comments
> 
> based on mmotm-2010-08-27
> 
> Patch brief view:
>  1. changes css ID allocation in kernel/cgroup.c
>  2. use ID-array in memcg.
>  3. record ID to page_cgroup rather than pointer.
>  4. make update_file_mapped to be RCU aware routine instead of spinlock.
>  5. make update_file_mapped as general-purpose function.
> 
> 

It seems that it will be better to re-order this series into

 A-part: lockless update of stats.
 B-part: ID managenet.

2 series. (to get ack.) Thank you for all helps.
BTW, what's the problem with ID patches ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
