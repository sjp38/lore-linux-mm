Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 79C852806F4
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 13:07:01 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id a110so14992523wrc.1
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 10:07:01 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 20si12946405edw.555.2017.08.22.10.06.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 22 Aug 2017 10:06:59 -0700 (PDT)
Date: Tue, 22 Aug 2017 13:06:55 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [v5 1/4] mm, oom: refactor the oom_kill_process() function
Message-ID: <20170822170655.GB13547@cmpxchg.org>
References: <20170814183213.12319-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170814183213.12319-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Aug 14, 2017 at 07:32:09PM +0100, Roman Gushchin wrote:
> @@ -817,67 +817,12 @@ static bool task_will_free_mem(struct task_struct *task)
>  	return ret;
>  }
>  
> -static void oom_kill_process(struct oom_control *oc, const char *message)
> +static void __oom_kill_process(struct task_struct *victim)

oom_kill_task()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
