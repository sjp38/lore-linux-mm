Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id F15776B0004
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 08:46:51 -0500 (EST)
Date: Mon, 21 Jan 2013 14:46:46 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: memcg: cat: memory.memsw.* : Operation not supported
Message-ID: <20130121134646.GL7798@dhcp22.suse.cz>
References: <4FEE7665.6020409@jp.fujitsu.com>
 <389106003.8637801.1358757547754.JavaMail.root@redhat.com>
 <20130121105624.GF7798@dhcp22.suse.cz>
 <50FD4245.3070402@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50FD4245.3070402@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhouping Liu <zliu@redhat.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Li Zefan <lizefan@huawei.com>, CAI Qian <caiqian@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>

On Mon 21-01-13 21:27:33, Zhouping Liu wrote:
> On 01/21/2013 06:56 PM, Michal Hocko wrote:
[...]
> > From 5f8141bf7d27014cfbc7b450f13f6146b5ab099d Mon Sep 17 00:00:00 2001
> >From: Michal Hocko <mhocko@suse.cz>
> >Date: Mon, 21 Jan 2013 11:33:26 +0100
> >Subject: [PATCH] memcg: Do not create memsw files if swap accounting is
> >  disabled
> >
> >Zhouping Liu has reported that memsw files are exported even though
> >swap accounting is runtime disabled if CONFIG_MEMCG_SWAP is enabled.
> >This behavior has been introduced by af36f906 (memcg: always create
> >memsw files if CONFIG_CGROUP_MEM_RES_CTLR_SWAP) and it causes any
> >attempt to open the file to return EOPNOTSUPP. Although EOPNOTSUPP
> >should say be clear that memsw operations are not supported in the given
> >configuration it is fair to say that this behavior could be quite
> >confusing.
> >
> >Let's tear memsw files out of default cgroup files and add
> >them only if the swap accounting is really enabled (either by
> >CONFIG_MEMCG_SWAP_ENABLED or swapaccount=1 boot parameter). We can
> >hook into mem_cgroup_init which is called when the memcg subsystem is
> >initialized and which happens after boot command line is processed.
> 
> Thanks for your quick patch, your patch looks good for me.
> 
> I tested it with or without CONFIG_MEMCG_SWAP_ENABLED=y,
> and also tested it with swapaccount=1 kernel parameters, all are okay.
> 
> Tested-by: Zhouping Liu <zliu@redhat.com>

Thanks for testing!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
