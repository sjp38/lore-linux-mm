Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 691086B004A
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 19:01:35 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 894BE3EE0BC
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 09:01:33 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D96645DE4E
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 09:01:33 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3FF9445DE50
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 09:01:33 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2FDEB1DB8042
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 09:01:33 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DC5371DB803E
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 09:01:32 +0900 (JST)
Date: Wed, 29 Feb 2012 09:00:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 1/2] kernel: cgroup: push rcu read locking from
 css_is_ancestor() to callsite
Message-Id: <20120229090005.1ef4cdb2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1330438489-21909-1-git-send-email-hannes@cmpxchg.org>
References: <1330438489-21909-1-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 28 Feb 2012 15:14:48 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> Library functions should not grab locks when the callsites can do it,
> even if the lock nests like the rcu read-side lock does.
> 
> Push the rcu_read_lock() from css_is_ancestor() to its single user,
> mem_cgroup_same_or_subtree() in preparation for another user that may
> already hold the rcu read-side lock.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
