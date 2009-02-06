Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id DE5A96B003D
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 22:11:06 -0500 (EST)
Message-ID: <498BAA22.50709@cn.fujitsu.com>
Date: Fri, 06 Feb 2009 11:10:26 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [-mm patch] Show memcg information during OOM (v3)
References: <20090203172135.GF918@balbir.in.ibm.com> <498BA857.3080809@cn.fujitsu.com>
In-Reply-To: <498BA857.3080809@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Li Zefan wrote:
>> +	mem_cgrp = memcg->css.cgroup;
>> +	task_cgrp = mem_cgroup_from_task(p)->css.cgroup;
> 
> I just noticed since v2, task's cgroup is also printed. Then 2 issues here:
> 
> 1. this is better: task_cgrp = task_subsys_state(p, mem_cgroup_subsys_id);

sorry, s/task_subsys_state/task_cgroup/

> 2. getting cgroup from a task should be protected by task_lock or rcu_read_lock,
>    so we can put the above statement inside rcu_read_lock below.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
