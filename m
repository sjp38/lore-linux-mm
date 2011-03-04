Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 5BCF68D0039
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 04:08:24 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 81A7A3EE0C1
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 18:08:19 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5FE9245DE50
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 18:08:19 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4449C45DE54
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 18:08:19 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 30AC21DB8037
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 18:08:19 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E93E9E78004
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 18:08:18 +0900 (JST)
Date: Fri, 4 Mar 2011 18:01:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Bugme-new] [Bug 30432] New: rmdir on cgroup can cause hang
 tasks
Message-Id: <20110304180157.133fdfd1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110304172815.9d9e3672.kamezawa.hiroyu@jp.fujitsu.com>
References: <bug-30432-10286@https.bugzilla.kernel.org/>
	<20110304000355.4f68bab1.akpm@linux-foundation.org>
	<20110304172815.9d9e3672.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daniel Poelzleithner <poelzi@poelzi.org>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, bugme-daemon@bugzilla.kernel.org, containers@lists.osdl.org, Paul Menage <menage@google.com>

On Fri, 4 Mar 2011 17:28:15 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
This seems....
> ==
> static void mem_cgroup_start_move(struct mem_cgroup *mem)
> {
> .....
> 	put_online_cpus();
> 
>         synchronize_rcu();   <---------(*)
> }
> ==
> 

But this may scan LRU of memcg forever and SysRq+T just shows
above stack.

I'll check a tree before THP and force_empty again
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
