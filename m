Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7E0DD6B0003
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 06:44:35 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id j25so2556802pfh.18
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 03:44:35 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id r14si2707142pgt.292.2018.04.19.03.44.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Apr 2018 03:44:34 -0700 (PDT)
Date: Thu, 19 Apr 2018 11:43:42 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: Some questions about cgroup aware OOM killer.
Message-ID: <20180419104336.GA20675@castle.DHCP.thefacebook.com>
References: <1524122224-26670-1-git-send-email-ufo19890607@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1524122224-26670-1-git-send-email-ufo19890607@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ufo19890607 <ufo19890607@gmail.com>
Cc: mhocko@suse.com, vdavydov.dev@gmail.com, penguin-kernel@i-love.sakura.ne.jp, rientjes@google.com, akpm@linux-foundation.org, tj@kernel.org, kernel-team@fb.com, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, yuzhoujian <yuzhoujian@didichuxing.com>

Hi!

Please, pull the whole patchset from the next tree:
git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git

$ git log next/master --oneline --author=guro@fb.com
1fecc970ac9e cgroup: list groupoom in cgroup features
dff73d397f7f mm-oom-docs-describe-the-cgroup-aware-oom-killer-fix
7cf83086511a mm, oom, docs: describe the cgroup-aware OOM killer
e2194b2869f1 mm, oom: add cgroup v2 mount option for cgroup-aware OOM killer
338fbcc52518 mm, oom: return error on access to memory.oom_group if groupoom is disabled
96fb32250ded mm, oom: introduce memory.oom_group
ed5f99985bf8 mm, oom: cgroup-aware OOM killer
e33eba2c3273 mm: implement mem_cgroup_scan_tasks() for the root memory cgroup
9bd3a4c529d4 mm, oom: refactor oom_kill_process()

Thanks!

On Thu, Apr 19, 2018 at 08:17:04AM +0100, ufo19890607 wrote:
> From: yuzhoujian <yuzhoujian@didichuxing.com>
> 
> Hi Roman
> I've read your patchset about cgroup aware OOM killer, and try
> to merge your patchset to the upstream kernel(v4.17-rc1). But
> I found some functions which in your patch([PATCH v13 3/7] 
> mm, oom: cgroup-aware OOM killer) does not exist in the upstream
> kernel. Which version of the kernel do you patch on? And, do you
> have the latest patchset?
> 
> The faults in PATCH v13 3/7:
> 1. mm/oom_kill.o: In function `out_of_memory':
>    /linux/mm/oom_kill.c:1125: undefined reference to `alloc_pages_before_oomkill'
> 2. mm/oom_kill.c: In function a??out_of_memorya??:
>    mm/oom_kill.c:1125:5: error: a??struct oom_controla?? has no member named a??pagea??
>    oc->page = alloc_pages_before_oomkill(oc);
>      ^
> 
> Best wishes
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
