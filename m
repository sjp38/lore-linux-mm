Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 991E26B0038
	for <linux-mm@kvack.org>; Tue, 16 Sep 2014 02:16:39 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id ft15so7925399pdb.18
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 23:16:39 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id uz1si27213472pac.182.2014.09.15.23.16.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 15 Sep 2014 23:16:38 -0700 (PDT)
Received: by mail-pa0-f48.google.com with SMTP id hz1so8232359pad.35
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 23:16:36 -0700 (PDT)
Date: Tue, 16 Sep 2014 15:16:30 +0900
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH RFC] memcg: revert kmem.tcp accounting
Message-ID: <20140916061630.GE805@mtj.dyndns.org>
References: <1410535618-9601-1-git-send-email-vdavydov@parallels.com>
 <20140912171809.GA24469@dhcp22.suse.cz>
 <20140912175516.GB6298@mtj.dyndns.org>
 <20140912144326.a8d5153d7c91d220ea89924a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140912144326.a8d5153d7c91d220ea89924a@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>, "David S. Miller" <davem@davemloft.net>, Johannes Weiner <hannes@cmpxchg.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Glauber Costa <glommer@gmail.com>, Pavel Emelianov <xemul@parallels.com>, Greg Thelen <gthelen@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, "Eric W. Biederman" <ebiederm@xmission.com>

Hello, Andrew.

On Fri, Sep 12, 2014 at 02:43:26PM -0700, Andrew Morton wrote:
> 17 files changed, 51 insertions(+), 761 deletions(-)
> 
> Sob.
> 
> Is there a convenient way of disabling the whole thing and adding a
> please-tell-us printk?  If nobody tells us for a year or two then zap.

Given that we're in the process of implementing the v2 interface, I
don't think it'd be wise to perturb v1 interface at this point.  We're
gonna have to carry around v1 code for quite some time anyway and I
don't think carrying the tcp code would make whole lot of difference
given that the code is likely to stay static from now on.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
