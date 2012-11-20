Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id B94B16B0072
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 23:23:55 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id D72B23EE0BD
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 13:23:53 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 75FBD45DEBA
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 13:23:53 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5967145DEB6
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 13:23:53 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 40FFB1DB803E
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 13:23:53 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id EA4391DB803B
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 13:23:52 +0900 (JST)
Message-ID: <50AB05B4.4000303@jp.fujitsu.com>
Date: Tue, 20 Nov 2012 13:23:16 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch] mm, memcg: avoid unnecessary function call when memcg
 is disabled
References: <alpine.DEB.2.00.1211191741060.24618@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1211191741060.24618@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org

(2012/11/20 10:44), David Rientjes wrote:
> While profiling numa/core v16 with cgroup_disable=memory on the command
> line, I noticed mem_cgroup_count_vm_event() still showed up as high as
> 0.60% in perftop.
>
> This occurs because the function is called extremely often even when memcg
> is disabled.
>
> To fix this, inline the check for mem_cgroup_disabled() so we avoid the
> unnecessary function call if memcg is disabled.
>
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
