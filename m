Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id CA3EE6B002C
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 20:35:37 -0500 (EST)
Message-ID: <4F4ED317.2090404@cn.fujitsu.com>
Date: Thu, 01 Mar 2012 09:38:31 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch 1/2] kernel: cgroup: push rcu read locking from css_is_ancestor()
 to callsite
References: <1330438489-21909-1-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1330438489-21909-1-git-send-email-hannes@cmpxchg.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Johannes Weiner wrote:
> Library functions should not grab locks when the callsites can do it,
> even if the lock nests like the rcu read-side lock does.
> 
> Push the rcu_read_lock() from css_is_ancestor() to its single user,
> mem_cgroup_same_or_subtree() in preparation for another user that may
> already hold the rcu read-side lock.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Li Zefan <lizf@cn.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
