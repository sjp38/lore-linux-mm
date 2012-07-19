Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id C54BC6B0072
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 06:13:22 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 606793EE0BD
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 19:13:21 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3FDA445DE59
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 19:13:21 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 220E045DE54
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 19:13:21 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 07067E18004
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 19:13:21 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3DB0C1DB8038
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 19:13:20 +0900 (JST)
Message-ID: <5007DD3B.8030703@jp.fujitsu.com>
Date: Thu, 19 Jul 2012 19:11:07 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH mmotm] mm, oom: reduce dependency on tasklist_lock: fix
References: <alpine.DEB.2.00.1206251846020.24838@chino.kir.corp.google.com> <alpine.DEB.2.00.1206291404530.6040@chino.kir.corp.google.com> <alpine.DEB.2.00.1206291406110.6040@chino.kir.corp.google.com> <20120713143206.GA4511@tiehlicka.suse.cz> <alpine.LSU.2.00.1207160039120.3936@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1207160039120.3936@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org

(2012/07/16 16:42), Hugh Dickins wrote:
> Slab poisoning gave me a General Protection Fault on the
> 	atomic_dec(&__task_cred(p)->user->processes);
> line of release_task() called from wait_task_zombie(),
> every time my dd to USB testing generated a memcg OOM.
>
> oom_kill_process() now does the put_task_struct(),
> mem_cgroup_out_of_memory() should not repeat it.
>
> Signed-off-by: Hugh Dickins <hughd@google.com>

Thank you for catching !

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
