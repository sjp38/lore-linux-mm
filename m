Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 382206B0038
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 03:52:36 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id gt1so6793618wjc.0
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 00:52:36 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s20si1281222wrb.195.2017.02.10.00.52.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Feb 2017 00:52:35 -0800 (PST)
Date: Fri, 10 Feb 2017 09:52:32 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] 3.10 kernel- oom with about 24G free memory
Message-ID: <20170210085232.GD10893@dhcp22.suse.cz>
References: <9a22aefd-dfb8-2e4c-d280-fc172893bcb4@huawei.com>
 <20170209132628.GI10257@dhcp22.suse.cz>
 <20170209134131.GJ10257@dhcp22.suse.cz>
 <ff8b1a0e-690e-74b5-3324-b99994591268@huawei.com>
 <20170210070930.GA9346@dhcp22.suse.cz>
 <7d01fea5-66d6-b6ac-918d-19ec8a15dbaf@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7d01fea5-66d6-b6ac-918d-19ec8a15dbaf@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hanjun Guo <guohanjun@huawei.com>

On Fri 10-02-17 16:48:58, Yisheng Xie wrote:
> Hi Michal,
> 
> Thanks for comment!
> On 2017/2/10 15:09, Michal Hocko wrote:
> > On Fri 10-02-17 09:13:58, Yisheng Xie wrote:
> >> hi Michal,
> >> Thanks for your comment.
> >>
> >> On 2017/2/9 21:41, Michal Hocko wrote:
[...]
> >>>> OK, so this is a memcg OOM killer which panics because the configuration
> >>>> says so. The OOM report doesn't say so and that is the bug. dump_header
> >>>> is memcg aware and mem_cgroup_out_of_memory initializes oom_control
> >>>> properly. Is this Vanilla kernel?
> >>
> >> That means we should raise the limit of that memcg to avoid memcg OOM killer, right?
> > 
> > Why do you configure the system to panic on memcg OOM in the first
> > place. This is a wrong thing to do in 99% of cases.
>
> For our production think it should use reboot to recovery the system when OOM,
> instead of killing user's key process. Maybe not the right thing.

I can understand that for the global oom killer but not for memcg. You
can recover the oom even without killing any process. You can simply
increase the limit from the userspace when the oom event is triggered.

Trigerring the panic on memcg oom killer is both dangerous and most
probably something you do not want.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
