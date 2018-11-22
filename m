Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9C72F6B2B01
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 08:39:57 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c3so4637638eda.3
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 05:39:57 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p26-v6si459834ejd.280.2018.11.22.05.39.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Nov 2018 05:39:55 -0800 (PST)
Date: Thu, 22 Nov 2018 14:39:54 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v15 2/2] Add oom victim's memcg to the oom context
 information
Message-ID: <20181122133954.GI18011@dhcp22.suse.cz>
References: <1542799799-36184-1-git-send-email-ufo19890607@gmail.com>
 <1542799799-36184-2-git-send-email-ufo19890607@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1542799799-36184-2-git-send-email-ufo19890607@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ufo19890607@gmail.com
Cc: akpm@linux-foundation.org, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, yuzhoujian@didichuxing.com

On Wed 21-11-18 19:29:59, ufo19890607@gmail.com wrote:
> From: yuzhoujian <yuzhoujian@didichuxing.com>
> 
> The current oom report doesn't display victim's memcg context during the
> global OOM situation. While this information is not strictly needed, it
> can be really helpful for containerized environments to locate which
> container has lost a process. Now that we have a single line for the oom
> context, we can trivially add both the oom memcg (this can be either
> global_oom or a specific memcg which hits its hard limits) and task_memcg
> which is the victim's memcg.
> 
> Below is the single line output in the oom report after this patch.
> - global oom context information:
> oom-kill:constraint=<constraint>,nodemask=<nodemask>,cpuset=<cpuset>,mems_allowed=<mems_allowed>,global_oom,task_memcg=<memcg>,task=<comm>,pid=<pid>,uid=<uid>
> - memcg oom context information:
> oom-kill:constraint=<constraint>,nodemask=<nodemask>,cpuset=<cpuset>,mems_allowed=<mems_allowed>,oom_memcg=<memcg>,task_memcg=<memcg>,task=<comm>,pid=<pid>,uid=<uid>
> 
> Signed-off-by: yuzhoujian <yuzhoujian@didichuxing.com>

I thought I have acked this one already.
Acked-by: Michal Hocko <mhocko@suse.com>
-- 
Michal Hocko
SUSE Labs
