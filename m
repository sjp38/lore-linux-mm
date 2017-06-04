Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3C9D16B0292
	for <linux-mm@kvack.org>; Sun,  4 Jun 2017 15:30:08 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id d198so25521390lfg.0
        for <linux-mm@kvack.org>; Sun, 04 Jun 2017 12:30:08 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id o184si3646264lfo.10.2017.06.04.12.30.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Jun 2017 12:30:06 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id f14so8144987lfe.1
        for <linux-mm@kvack.org>; Sun, 04 Jun 2017 12:30:06 -0700 (PDT)
Date: Sun, 4 Jun 2017 22:30:02 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [RFC PATCH v2 4/7] mm, oom: introduce oom_kill_all_tasks option
 for memory cgroups
Message-ID: <20170604193002.GB19980@esperanza>
References: <1496342115-3974-1-git-send-email-guro@fb.com>
 <1496342115-3974-5-git-send-email-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1496342115-3974-5-git-send-email-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Jun 01, 2017 at 07:35:12PM +0100, Roman Gushchin wrote:
> This option defines whether a cgroup should be treated
> as a single entity by the OOM killer.
> 
> If set, the OOM killer will compare the whole cgroup with other
> memory consumers (other cgroups and tasks in the root cgroup),
> and in case of an OOM will kill all belonging tasks.
> 
> Disabled by default.
> 
...
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> @@ -5265,6 +5292,12 @@ static struct cftype memory_files[] = {
>  		.write = memory_max_write,
>  	},
>  	{
> +		.name = "oom_kill_all_tasks",
> +		.flags = CFTYPE_NOT_ON_ROOT,
> +		.seq_show = memory_oom_kill_all_tasks_show,
> +		.write = memory_oom_kill_all_tasks_write,
> +	},
> +	{
>  		.name = "events",
>  		.flags = CFTYPE_NOT_ON_ROOT,
>  		.file_offset = offsetof(struct mem_cgroup, events_file),

I don't really like the name of the new knob, but can't come up with
anything better :-( May be, drop '_tasks' suffix and call it just
'oom_kill_all'? Or perhaps we should emphasize the fact that this
cgroup is treated as a single entity by the OOM killer by calling it
'oom_entity' or 'oom_unit'? Dunno...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
