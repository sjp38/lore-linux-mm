Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0D9806B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 09:39:07 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k7so4424171wre.5
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 06:39:07 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s13si5082250wrg.184.2017.10.03.06.39.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Oct 2017 06:39:05 -0700 (PDT)
Date: Tue, 3 Oct 2017 15:39:03 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v9 4/5] mm, oom: add cgroup v2 mount option for cgroup-aware
 OOM killer
Message-ID: <20171003133903.liakwvkbnowzlkk6@dhcp22.suse.cz>
References: <20170927130936.8601-1-guro@fb.com>
 <20170927130936.8601-5-guro@fb.com>
 <20171003115036.3zzydsiiz7hbx4jg@dhcp22.suse.cz>
 <20171003124936.GA28904@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171003124936.GA28904@castle.DHCP.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 03-10-17 13:49:36, Roman Gushchin wrote:
> On Tue, Oct 03, 2017 at 01:50:36PM +0200, Michal Hocko wrote:
> > On Wed 27-09-17 14:09:35, Roman Gushchin wrote:
> > > Add a "groupoom" cgroup v2 mount option to enable the cgroup-aware
> > > OOM killer. If not set, the OOM selection is performed in
> > > a "traditional" per-process way.
> > > 
> > > The behavior can be changed dynamically by remounting the cgroupfs.
> > 
> > I do not have a strong preference about this. I would just be worried
> > that it is usually systemd which tries to own the whole hierarchy
> 
> I actually like this fact.
> 
> It gives us the opportunity to change the default behavior for most users
> at the point when we'll be sure that new behavior is better; but at the same
> time we'll save full compatibility on the kernel level.

Well, I would be much more skeptical because I simply believe that
neither of the approach is better in general. It really depends on the
usecases. And systemd or whoever mounts the hierarchy has no slightest
idea what is the case. So we might end up with a global knob to control
the mount point after all. But as I've said no strong opinion on that.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
