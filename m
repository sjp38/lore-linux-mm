Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 055196B0036
	for <linux-mm@kvack.org>; Tue,  1 Oct 2013 20:46:27 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id w10so121630pde.37
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 17:46:27 -0700 (PDT)
Received: by mail-qc0-f176.google.com with SMTP id t7so70635qcv.7
        for <linux-mm@kvack.org>; Tue, 01 Oct 2013 17:46:24 -0700 (PDT)
Message-ID: <524B6D05.5030609@gmail.com>
Date: Tue, 01 Oct 2013 20:47:01 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [patch for-3.12] mm, memcg: protect mem_cgroup_read_events for
 cpu hotplug
References: <alpine.DEB.2.02.1310011629350.27758@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1310011629350.27758@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kosaki.motohiro@gmail.com

(10/1/13 7:31 PM), David Rientjes wrote:
> for_each_online_cpu() needs the protection of {get,put}_online_cpus() so
> cpu_online_mask doesn't change during the iteration.
>
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
