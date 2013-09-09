Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id EB10B6B0031
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 05:00:28 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so5893194pbb.0
        for <linux-mm@kvack.org>; Mon, 09 Sep 2013 02:00:28 -0700 (PDT)
Date: Mon, 9 Sep 2013 02:00:26 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, memcg: store memcg name for oom kill log
 consistency
In-Reply-To: <20130905135219.GE13666@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1309090200110.1935@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1308282302450.14291@chino.kir.corp.google.com> <20130829133032.GB12077@dhcp22.suse.cz> <20130905135219.GE13666@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 5 Sep 2013, Michal Hocko wrote:

> From 4cee36f56100f5689fe1ae22f468016ce5a0cbae Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Thu, 5 Sep 2013 15:39:20 +0200
> Subject: [PATCH] memcg, oom: lock mem_cgroup_print_oom_info
> 
> mem_cgroup_print_oom_info uses a static buffer (memcg_name) to store the
> name of the cgroup. This is not safe as pointed out by David Rientjes
> because although memcg oom is locked for its hierarchy nothing prevents
> another parallel hierarchy to trigger oom as well and overwrite the
> already in-use buffer.
> 
> This patch introduces oom_info_lock hidden inside mem_cgroup_print_oom_info
> which is held throughout the function. It make access to memcg_name safe
> and as a bonus it also prevents parallel memcg ooms to interleave their
> statistics which would make the printed data hard to analyze otherwise.
> 
> Using the spinlock is OK here because this path is not hot and
> meaningful data is much more important.
> 
> Reported-by: David Rientjes <rientjes@google.com>

Remove this.

> Signed-off-by: Michal Hocko <mhocko@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
