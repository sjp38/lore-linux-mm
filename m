Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id BF4466B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 02:12:33 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so6319063pad.14
        for <linux-mm@kvack.org>; Mon, 15 Oct 2012 23:12:33 -0700 (PDT)
Date: Mon, 15 Oct 2012 23:12:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom, memcg: handle sysctl oom_kill_allocating_task while
 memcg oom happening
In-Reply-To: <1350367837-27919-1-git-send-email-handai.szj@taobao.com>
Message-ID: <alpine.DEB.2.00.1210152311460.9480@chino.kir.corp.google.com>
References: <1350367837-27919-1-git-send-email-handai.szj@taobao.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@taobao.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, mhocko@suse.cz, linux-kernel@vger.kernel.org

On Tue, 16 Oct 2012, Sha Zhengju wrote:

> From: Sha Zhengju <handai.szj@taobao.com>
> 
> Sysctl oom_kill_allocating_task enables or disables killing the OOM-triggering
> task in out-of-memory situations, but it only works on overall system-wide oom.
> But it's also a useful indication in memcg so we take it into consideration
> while oom happening in memcg. Other sysctl such as panic_on_oom has already
> been memcg-ware.
> 

You're working on an old kernel, mem_cgroup_out_of_memory() has moved to 
mm/memcontrol.c.  Please rebase on 3.7-rc1 and send an updated patch, 
which otherwise looks good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
