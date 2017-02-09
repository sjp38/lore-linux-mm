Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3F8006B0388
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 08:41:29 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 204so4904581pge.5
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 05:41:29 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 1si10074060pgr.272.2017.02.09.05.41.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Feb 2017 05:41:28 -0800 (PST)
Subject: Re: [RFC] 3.10 kernel- oom with about 24G free memory
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <9a22aefd-dfb8-2e4c-d280-fc172893bcb4@huawei.com>
	<20170209132628.GI10257@dhcp22.suse.cz>
In-Reply-To: <20170209132628.GI10257@dhcp22.suse.cz>
Message-Id: <201702092241.FEH35923.tOMJVHLSFFQOFO@I-love.SAKURA.ne.jp>
Date: Thu, 9 Feb 2017 22:41:11 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, xieyisheng1@huawei.com
Cc: vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, guohanjun@huawei.com

Michal Hocko wrote:
> On Thu 09-02-17 20:54:49, Yisheng Xie wrote:
> > Hi all,
> > I get an oom on a linux 3.10 kvm guest OS. when it triggers the oom
> > it have about 24G free memory(and host OS have about 10G free memory)
> > and watermark is sure ok.
> > 
> > I also check about about memcg limit value, also cannot find the
> > root cause.
> > 
> > Is there anybody ever meet similar problem and have any idea about it?
> > 
> > Any comment is more than welcome!
> > 
> > Thanks
> > Yisheng Xie
> > 
> > -------------
> > [   81.234289] DefSch0200 invoked oom-killer: gfp_mask=0xd0, order=0, oom_score_adj=0
> > [   81.234295] DefSch0200 cpuset=/ mems_allowed=0
> > [   81.234299] CPU: 3 PID: 8284 Comm: DefSch0200 Tainted: G           O E ----V-------   3.10.0-229.42.1.105.x86_64 #1
> > [   81.234301] Hardware name: OpenStack Foundation OpenStack Nova, BIOS rel-1.8.1-0-g4adadbd-20161111_105425-HGH1000008200 04/01/2014
> > [   81.234303]  ffff880ae2900000 000000002b3489d7 ffff880b6cec7c58 ffffffff81608d3d
> > [   81.234307]  ffff880b6cec7ce8 ffffffff81603d1c 0000000000000000 ffff880b6cd09000
> > [   81.234311]  ffff880b6cec7cd8 000000002b3489d7 ffff880b6cec7ce0 ffffffff811bdd77
> > [   81.234314] Call Trace:
> > [   81.234323]  [<ffffffff81608d3d>] dump_stack+0x19/0x1b
> > [   81.234327]  [<ffffffff81603d1c>] dump_header+0x8e/0x214
> > [   81.234333]  [<ffffffff811bdd77>] ? mem_cgroup_iter+0x177/0x2b0
> > [   81.234339]  [<ffffffff8115d83e>] check_panic_on_oom+0x2e/0x60
> > [   81.234342]  [<ffffffff811c17bf>] mem_cgroup_oom_synchronize+0x34f/0x580
> 
> OK, so this is a memcg OOM killer which panics because the configuration
> says so. The OOM report doesn't say so and that is the bug. dump_header
> is memcg aware and mem_cgroup_out_of_memory initializes oom_control
> properly. Is this Vanilla kernel?

No. Google says kernel-3.10.0-229.42.1.105.x86_64.rpm at
http://developer.huawei.com/ict/site-euleros/euleros/repo/yum/os/base/2.1/updates/1/Packages/ .

> -- 
> Michal Hocko
> SUSE Labs
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
