Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 4C78D6B0073
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 01:54:18 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id DD3AF3EE0BD
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 14:54:16 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C32DE45DE52
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 14:54:16 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id AAE3745DE4E
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 14:54:16 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 98F8E1DB802F
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 14:54:16 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 402241DB803B
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 14:54:16 +0900 (JST)
Message-ID: <4FF3D9FD.6080502@jp.fujitsu.com>
Date: Wed, 04 Jul 2012 14:51:57 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch 5/5] mm, memcg: move all oom handling to memcontrol.c
References: <alpine.DEB.2.00.1206251846020.24838@chino.kir.corp.google.com> <alpine.DEB.2.00.1206291404530.6040@chino.kir.corp.google.com> <alpine.DEB.2.00.1206291406270.6040@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1206291406270.6040@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, cgroups@vger.kernel.org

(2012/06/30 6:07), David Rientjes wrote:
> By globally defining check_panic_on_oom(), the memcg oom handler can be
> moved entirely to mm/memcontrol.c.  This removes the ugly #ifdef in the
> oom killer and cleans up the code.
>
> Signed-off-by: David Rientjes <rientjes@google.com>

Thank you.
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
