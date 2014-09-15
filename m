Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id D9C456B0035
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 03:36:26 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id p10so5670633pdj.30
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 00:36:26 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id zq7si21189829pbc.95.2014.09.15.00.36.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Sep 2014 00:36:23 -0700 (PDT)
Date: Mon, 15 Sep 2014 11:36:00 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH RFC] memcg: revert kmem.tcp accounting
Message-ID: <20140915073600.GA11353@esperanza>
References: <1410535618-9601-1-git-send-email-vdavydov@parallels.com>
 <20140912171809.GA24469@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20140912171809.GA24469@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, "David S. Miller" <davem@davemloft.net>, Johannes Weiner <hannes@cmpxchg.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Glauber Costa <glommer@gmail.com>, Pavel Emelianov <xemul@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, "Eric W. Biederman" <ebiederm@xmission.com>

Hi Michal,

On Fri, Sep 12, 2014 at 07:18:09PM +0200, Michal Hocko wrote:
> On Fri 12-09-14 19:26:58, Vladimir Davydov wrote:
> > memory.kmem.tcp.limit_in_bytes works as the system-wide tcp_mem sysctl,
> > but per memory cgroup. While the existence of the latter is justified
> > (it prevents the system from becoming unusable due to uncontrolled tcp
> > buffers growth) the reason why we need such a knob in containers isn't
> > clear to me.
> 
> Parallels was the primary driver for this change. I haven't heard of
> anybody using the feature other than Parallels. I also remember there
> was a strong push for this feature before it was merged besides there
> were some complains at the time. I do not remember details (and I am
> one half way gone for the weekend now) so I do not have pointers to
> discussions.
> 
> I would love to get rid of the code and I am pretty sure that networking
> people would love this go even more. I didn't plan to provide kmem.tcp.*
> knobs for the cgroups v2 interface but getting rid of it altogether
> sounds even better. I am just not sure whether some additional users
> grown over time.
> Nevertheless I am really curious. What has changed that Parallels is not
> interested in kmem.tcp anymore?

In our product (OpenVZ) we have home-bred counters for many types of
resources, but we stopped setting limits for most of them, including tcp
buffers accounting, long time ago, and our customers don't set them
either. In the next product release we are going to drop them all and
use only mem, anon+swap, and kmem limits.

I don't know what was the reason to push this stuff, because I wasn't in
it at that time. From what I read from comments to the patches I found
it was something like the first step towards kmem accounting. However,
if we had fully functioning kmem accounting there would be no point in
this.

> 
> [...]
> 
> Anyway, more than welcome
> Acked-by: Michal Hocko <mhocko@suse.cz>

Thank you.

> 
> In case we happened to grow more users, which I hope hasn't happened, we
> would need to keep this around at least with the legacy cgroups API.

The whole CONFIG_MEMCG_KMEM is marked as DON'T ENABLE IT, BECAUSE IT
DOESN'T WORK (kudos to you). That's why I think we could probably close
our eye to wailing users if any.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
