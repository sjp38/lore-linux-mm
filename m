Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 91DC26B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 08:50:08 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id w79so1716811wrc.19
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 05:50:08 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id z4si5149857lfj.374.2017.10.03.05.50.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Oct 2017 05:50:07 -0700 (PDT)
Date: Tue, 3 Oct 2017 13:49:36 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v9 4/5] mm, oom: add cgroup v2 mount option for cgroup-aware
 OOM killer
Message-ID: <20171003124936.GA28904@castle.DHCP.thefacebook.com>
References: <20170927130936.8601-1-guro@fb.com>
 <20170927130936.8601-5-guro@fb.com>
 <20171003115036.3zzydsiiz7hbx4jg@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20171003115036.3zzydsiiz7hbx4jg@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Oct 03, 2017 at 01:50:36PM +0200, Michal Hocko wrote:
> On Wed 27-09-17 14:09:35, Roman Gushchin wrote:
> > Add a "groupoom" cgroup v2 mount option to enable the cgroup-aware
> > OOM killer. If not set, the OOM selection is performed in
> > a "traditional" per-process way.
> > 
> > The behavior can be changed dynamically by remounting the cgroupfs.
> 
> I do not have a strong preference about this. I would just be worried
> that it is usually systemd which tries to own the whole hierarchy

I actually like this fact.

It gives us the opportunity to change the default behavior for most users
at the point when we'll be sure that new behavior is better; but at the same
time we'll save full compatibility on the kernel level.
With growing popularity of memory cgroups, I don't think that hiding
this functionality with a boot option makes any sense. It's just not
this type of feature, that should be hidden.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
