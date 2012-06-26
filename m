Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 1593A6B00CF
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 23:14:42 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 9AB323EE0AE
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 12:14:40 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 80F3345DEB2
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 12:14:40 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 694BE45DE9E
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 12:14:40 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 566701DB8040
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 12:14:40 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0DFF01DB803C
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 12:14:40 +0900 (JST)
Message-ID: <4FE9289B.2050105@jp.fujitsu.com>
Date: Tue, 26 Jun 2012 12:12:27 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch 1/3] mm, oom: move declaration for mem_cgroup_out_of_memory
 to oom.h
References: <alpine.DEB.2.00.1206251846020.24838@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1206251846020.24838@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org

(2012/06/26 10:47), David Rientjes wrote:
> mem_cgroup_out_of_memory() is defined in mm/oom_kill.c, so declare it in
> linux/oom.h rather than linux/memcontrol.h.
>
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
