Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 44E8C6B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 14:39:55 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id t21so8965952wrb.14
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 11:39:55 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q2si10347400wrc.267.2018.01.30.11.39.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jan 2018 11:39:54 -0800 (PST)
Date: Tue, 30 Jan 2018 11:39:50 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch -mm v2 2/3] mm, memcg: replace cgroup aware oom killer
 mount option with tunable
Message-Id: <20180130113950.f462c4575a9d8a008162a874@linux-foundation.org>
In-Reply-To: <20180130122011.GB21609@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1801261415090.15318@chino.kir.corp.google.com>
	<20180126143950.719912507bd993d92188877f@linux-foundation.org>
	<alpine.DEB.2.10.1801261441340.20954@chino.kir.corp.google.com>
	<20180126161735.b999356fbe96c0acd33aaa66@linux-foundation.org>
	<20180129104657.GC21609@dhcp22.suse.cz>
	<20180129191139.GA1121507@devbig577.frc2.facebook.com>
	<20180130085445.GQ21609@dhcp22.suse.cz>
	<20180130115846.GA4720@castle.DHCP.thefacebook.com>
	<20180130120852.GA21609@dhcp22.suse.cz>
	<20180130121315.GA5888@castle.DHCP.thefacebook.com>
	<20180130122011.GB21609@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 30 Jan 2018 13:20:11 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> Subject: [PATCH] oom, memcg: clarify root memcg oom accounting
> 
> David Rientjes has pointed out that the current way how the root memcg
> is accounted for the cgroup aware OOM killer is undocumented. Unlike
> regular cgroups there is no accounting going on in the root memcg
> (mostly for performance reasons). Therefore we are suming up oom_badness
> of its tasks. This might result in an over accounting because of the
> oom_score_adj setting. Document this for now.

Thanks.  Some tweakage:

--- a/Documentation/cgroup-v2.txt~mm-oom-docs-describe-the-cgroup-aware-oom-killer-fix-2-fix
+++ a/Documentation/cgroup-v2.txt
@@ -1292,13 +1292,13 @@ of the OOM'ing cgroup.
 
 Leaf cgroups and cgroups with oom_group option set are compared based
 on their cumulative memory usage. The root cgroup is treated as a
-leaf memory cgroup as well, so it's compared with other leaf memory
+leaf memory cgroup as well, so it is compared with other leaf memory
 cgroups. Due to internal implementation restrictions the size of
-the root cgroup is a cumulative sum of oom_badness of all its tasks
+the root cgroup is the cumulative sum of oom_badness of all its tasks
 (in other words oom_score_adj of each task is obeyed). Relying on
-oom_score_adj (appart from OOM_SCORE_ADJ_MIN) can lead to over or
-underestimating of the root cgroup consumption and it is therefore
-discouraged. This might change in the future, though.
+oom_score_adj (apart from OOM_SCORE_ADJ_MIN) can lead to over- or
+underestimation of the root cgroup consumption and it is therefore
+discouraged. This might change in the future, however.
 
 If there are no cgroups with the enabled memory controller,
 the OOM killer is using the "traditional" process-based approach.
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
