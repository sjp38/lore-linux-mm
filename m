Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 0626C6B0044
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 04:27:01 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n089QxsJ011308
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 8 Jan 2009 18:26:59 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F0F145DE4F
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 18:26:59 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 200E445DE53
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 18:26:59 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id DB10A1DB803F
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 18:26:58 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 157C9EF8002
	for <linux-mm@kvack.org>; Thu,  8 Jan 2009 18:26:58 +0900 (JST)
Date: Thu, 8 Jan 2009 18:25:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] cgroup and memcg updates 20090108
Message-Id: <20090108182556.621e3ee6.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

Request for comments for 4 cgroup/memcg patches.
 
 [1/4] CSS ID support for cgroup
    minor update from the last year.

 [2/4] use CSS ID in memcg
    minor update

 [3/4] fix oom-kill problem of memcg/hierarchy=1
    minor update, but I'm still looking for better fix.

 [4/4] fix frequest -EBUSY at rmdir().
     New one. I need advices.

I'd like to remove RFC of some of them in the next week.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
