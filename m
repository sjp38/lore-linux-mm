Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
	by kanga.kvack.org (Postfix) with ESMTP id 66DA66B0037
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 13:18:18 -0400 (EDT)
Received: by mail-we0-f172.google.com with SMTP id k48so1069547wev.31
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 10:18:15 -0700 (PDT)
Received: from mail-wi0-x232.google.com (mail-wi0-x232.google.com [2a00:1450:400c:c05::232])
        by mx.google.com with ESMTPS id fq2si3953860wic.44.2014.09.12.10.18.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 12 Sep 2014 10:18:12 -0700 (PDT)
Received: by mail-wi0-f178.google.com with SMTP id ho1so1052102wib.17
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 10:18:12 -0700 (PDT)
Date: Fri, 12 Sep 2014 19:18:09 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH RFC] memcg: revert kmem.tcp accounting
Message-ID: <20140912171809.GA24469@dhcp22.suse.cz>
References: <1410535618-9601-1-git-send-email-vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1410535618-9601-1-git-send-email-vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, "David S. Miller" <davem@davemloft.net>, Johannes Weiner <hannes@cmpxchg.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Glauber Costa <glommer@gmail.com>, Pavel Emelianov <xemul@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, "Eric W. Biederman" <ebiederm@xmission.com>

On Fri 12-09-14 19:26:58, Vladimir Davydov wrote:
> memory.kmem.tcp.limit_in_bytes works as the system-wide tcp_mem sysctl,
> but per memory cgroup. While the existence of the latter is justified
> (it prevents the system from becoming unusable due to uncontrolled tcp
> buffers growth) the reason why we need such a knob in containers isn't
> clear to me.

Parallels was the primary driver for this change. I haven't heard of
anybody using the feature other than Parallels. I also remember there
was a strong push for this feature before it was merged besides there
were some complains at the time. I do not remember details (and I am
one half way gone for the weekend now) so I do not have pointers to
discussions.

I would love to get rid of the code and I am pretty sure that networking
people would love this go even more. I didn't plan to provide kmem.tcp.*
knobs for the cgroups v2 interface but getting rid of it altogether
sounds even better. I am just not sure whether some additional users
grown over time.
Nevertheless I am really curious. What has changed that Parallels is not
interested in kmem.tcp anymore?

[...]

Anyway, more than welcome
Acked-by: Michal Hocko <mhocko@suse.cz>

In case we happened to grow more users, which I hope hasn't happened, we
would need to keep this around at least with the legacy cgroups API.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
