Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 1180D6B0036
	for <linux-mm@kvack.org>; Tue, 16 Sep 2014 04:38:32 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id z10so8126385pdj.20
        for <linux-mm@kvack.org>; Tue, 16 Sep 2014 01:38:31 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ef1si20837781pbc.144.2014.09.16.01.38.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Sep 2014 01:38:31 -0700 (PDT)
Date: Tue, 16 Sep 2014 12:38:10 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH RFC] memcg: revert kmem.tcp accounting
Message-ID: <20140916083810.GB32139@esperanza>
References: <1410535618-9601-1-git-send-email-vdavydov@parallels.com>
 <20140912171809.GA24469@dhcp22.suse.cz>
 <20140912175516.GB6298@mtj.dyndns.org>
 <20140915074257.GB11353@esperanza>
 <20140916061401.GD805@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20140916061401.GD805@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>, "David S. Miller" <davem@davemloft.net>, Johannes Weiner <hannes@cmpxchg.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Glauber Costa <glommer@gmail.com>, Pavel Emelianov <xemul@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, "Eric W. Biederman" <ebiederm@xmission.com>

On Tue, Sep 16, 2014 at 03:14:01PM +0900, Tejun Heo wrote:
> I don't think marking config options as "UNDER DEVELOPMENT" in its
> help documentation means anything.  It's a rather silly thing to do.
> Not many people pay much attention to the help texts and once somebody
> somewhere enabled the option for a distro, it's as free in the wild as
> any other kernel feature and CONFIG_MEMCG_KMEM is enabled by a lot of
> distros.  The same goes with the "debug" controller.  It doesn't mean
> much that it has "debug" in its name.  Once it's out in the wild,
> there will be someone making use of it in some weird way.
> 
> If a debug feature has to be in the mainline kernel, the fact that
> it's a debug feature must be explicitly chosen in each use.  IOW, gate
> it by an unwieldy boot param which makes it painfully clear that it's
> enabling an unstable debug feature and print out a loud warning
> message about it.
> 
> As it currently stands, CONFIG_MEMCG_KMEM is as good as any other
> enabled kernel option.  The help text saying that it's experimental
> does not mean anything especially when it doesn't even depend on
> CONFIG_BROKEN.
> 
> So, the argument "the option was explained as experimental in help
> text" doesn't fly at all.  We can still try to deprecate it gradually
> if the cleanup seems worthwhile; however, with v2 interface pending,
> I'm not sure how meaningful that'd be.  We'd have to carry quite a bit
> of v1 code around anyway and I'd like to keep v1 interface as static
> as possible.  No reason to shake that at this point.

Fair enough, thank you for the clarification. I hope we'll be able to
get rid of it in a year or two when cgroup v2 becomes stable.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
