Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id F0AF36B0038
	for <linux-mm@kvack.org>; Sat, 19 Sep 2015 04:25:08 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so58224710wic.0
        for <linux-mm@kvack.org>; Sat, 19 Sep 2015 01:25:08 -0700 (PDT)
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com. [209.85.212.176])
        by mx.google.com with ESMTPS id gt4si3020707wib.57.2015.09.19.01.25.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 Sep 2015 01:25:08 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so55388325wic.1
        for <linux-mm@kvack.org>; Sat, 19 Sep 2015 01:25:07 -0700 (PDT)
Date: Sat, 19 Sep 2015 10:25:06 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/oom_kill.c: don't kill TASK_UNINTERRUPTIBLE tasks
Message-ID: <20150919082506.GC28815@dhcp22.suse.cz>
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com>
 <20150917192204.GA2728@redhat.com>
 <alpine.DEB.2.11.1509181035180.11189@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1509181035180.11189@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Oleg Nesterov <oleg@redhat.com>, Kyle Walker <kwalker@redhat.com>, akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Stanislav Kozina <skozina@redhat.com>

On Fri 18-09-15 10:41:09, Christoph Lameter wrote:
[...]
>  	if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
> -		if (oc->order != -1)
> -			return OOM_SCAN_ABORT;
> +		if (unlikely(frozen(task)))
> +			__thaw_task(task);

TIF_MEMDIE processes will get thawed automatically and then cannot be
frozen again. Have a look at mark_oom_victim.

>  	}
>  	if (!task->mm)
>  		return OOM_SCAN_CONTINUE;

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
