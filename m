Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8A3DE6B0007
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 10:15:53 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id f16so11243062qth.20
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 07:15:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r85sor2069405qki.119.2018.01.30.07.15.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Jan 2018 07:15:52 -0800 (PST)
Date: Tue, 30 Jan 2018 07:15:49 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch -mm v2 2/3] mm, memcg: replace cgroup aware oom killer
 mount option with tunable
Message-ID: <20180130151549.GE1121507@devbig577.frc2.facebook.com>
References: <20180126143950.719912507bd993d92188877f@linux-foundation.org>
 <alpine.DEB.2.10.1801261441340.20954@chino.kir.corp.google.com>
 <20180126161735.b999356fbe96c0acd33aaa66@linux-foundation.org>
 <20180129104657.GC21609@dhcp22.suse.cz>
 <20180129191139.GA1121507@devbig577.frc2.facebook.com>
 <20180130085445.GQ21609@dhcp22.suse.cz>
 <20180130115846.GA4720@castle.DHCP.thefacebook.com>
 <20180130120852.GA21609@dhcp22.suse.cz>
 <20180130121315.GA5888@castle.DHCP.thefacebook.com>
 <20180130122011.GB21609@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180130122011.GB21609@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jan 30, 2018 at 01:20:11PM +0100, Michal Hocko wrote:
> From 361275a05ad7026b8f721f8aa756a4975a2c42b1 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Tue, 30 Jan 2018 09:54:15 +0100
> Subject: [PATCH] oom, memcg: clarify root memcg oom accounting
> 
> David Rientjes has pointed out that the current way how the root memcg
> is accounted for the cgroup aware OOM killer is undocumented. Unlike
> regular cgroups there is no accounting going on in the root memcg
> (mostly for performance reasons). Therefore we are suming up oom_badness
> of its tasks. This might result in an over accounting because of the
> oom_score_adj setting. Document this for now.
> 
> Acked-by: Roman Gushchin <guro@fb.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks, Michal.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
