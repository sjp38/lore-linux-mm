Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9AA6A6B003D
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 20:36:11 -0500 (EST)
Message-ID: <4988F0E4.3010404@cn.fujitsu.com>
Date: Wed, 04 Feb 2009 09:35:32 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [-mm patch] Show memcg information during OOM (v3)
References: <20090203172135.GF918@balbir.in.ibm.com> <4988E727.8030807@cn.fujitsu.com>
In-Reply-To: <4988E727.8030807@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>> +void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
>> +{
>> +	struct cgroup *task_cgrp;
>> +	struct cgroup *mem_cgrp;
>> +	/*
>> +	 * Need a buffer on stack, can't rely on allocations. The code relies
> 
> I think it's in .bss section, but not on stack

> and it's better to explain why
> the static buffer is safe in the comment.
> 

Sorry, I just saw the below comment.

>> +	 * on the assumption that OOM is serialized for memory controller.
>> +	 * If this assumption is broken, revisit this code.
>> +	 */
>> +	static char task_memcg_name[PATH_MAX];
>> +	static char memcg_name[PATH_MAX];
>> +	int ret;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
