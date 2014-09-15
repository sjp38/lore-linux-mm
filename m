Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id EAA846B0035
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 03:43:16 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id fp1so5647893pdb.28
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 00:43:16 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id qq6si21340784pbb.23.2014.09.15.00.43.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Sep 2014 00:43:13 -0700 (PDT)
Date: Mon, 15 Sep 2014 11:42:57 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH RFC] memcg: revert kmem.tcp accounting
Message-ID: <20140915074257.GB11353@esperanza>
References: <1410535618-9601-1-git-send-email-vdavydov@parallels.com>
 <20140912171809.GA24469@dhcp22.suse.cz>
 <20140912175516.GB6298@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20140912175516.GB6298@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>, "David S. Miller" <davem@davemloft.net>, Johannes
 Weiner <hannes@cmpxchg.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Glauber Costa <glommer@gmail.com>, Pavel
 Emelianov <xemul@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, "Eric W. Biederman" <ebiederm@xmission.com>

Hi Tejun,

On Sat, Sep 13, 2014 at 02:55:16AM +0900, Tejun Heo wrote:
> Hello, guys.
> 
> On Fri, Sep 12, 2014 at 07:18:09PM +0200, Michal Hocko wrote:
> > On Fri 12-09-14 19:26:58, Vladimir Davydov wrote:
> > > memory.kmem.tcp.limit_in_bytes works as the system-wide tcp_mem sysctl,
> > > but per memory cgroup. While the existence of the latter is justified
> > > (it prevents the system from becoming unusable due to uncontrolled tcp
> > > buffers growth) the reason why we need such a knob in containers isn't
> > > clear to me.
> > 
> > Parallels was the primary driver for this change. I haven't heard of
> > anybody using the feature other than Parallels. I also remember there
> > was a strong push for this feature before it was merged besides there
> > were some complains at the time. I do not remember details (and I am
> > one half way gone for the weekend now) so I do not have pointers to
> > discussions.
> > 
> > I would love to get rid of the code and I am pretty sure that networking
> > people would love this go even more. I didn't plan to provide kmem.tcp.*
> > knobs for the cgroups v2 interface but getting rid of it altogether
> > sounds even better. I am just not sure whether some additional users
> > grown over time.
> > Nevertheless I am really curious. What has changed that Parallels is not
> > interested in kmem.tcp anymore?
> 
> So, I'd love to see this happen too but I don't think we can do this.
> People use published interface.  The usages might be utterly one-off
> and mental but let's please not underestimate the sometimes senseless
> creativity found in the wild.  We simply can't remove a bunch of
> control knobs like this.

We definitely can't remove something properly operating and widely used,
but kmem limits are not working and never worked properly due to lack of
kmem shrinkers, and furthermore CONFIG_MEMCG_KMEM, which tcp accounting
is enabled by, is marked as UNDER DEVELOPMENT.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
