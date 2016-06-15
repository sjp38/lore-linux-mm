Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f70.google.com (mail-qg0-f70.google.com [209.85.192.70])
	by kanga.kvack.org (Postfix) with ESMTP id 13B836B0260
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 11:03:33 -0400 (EDT)
Received: by mail-qg0-f70.google.com with SMTP id a95so49025671qgf.2
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 08:03:33 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t38si22513871qgt.91.2016.06.15.08.03.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jun 2016 08:03:26 -0700 (PDT)
Date: Wed, 15 Jun 2016 17:03:21 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 04/10] mm, oom_adj: make sure processes sharing mm have
 same view of oom_score_adj
Message-ID: <20160615150321.GD7944@redhat.com>
References: <1465473137-22531-1-git-send-email-mhocko@kernel.org>
 <1465473137-22531-5-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1465473137-22531-5-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 06/09, Michal Hocko wrote:
>
> +			if (!p->vfork_done && process_shares_mm(p, mm)) {
> +				pr_info("updating oom_score_adj for %d (%s) from %d to %d because it shares mm with %d (%s). Report if this is unexpected.\n",
> +						task_pid_nr(p), p->comm,
> +						p->signal->oom_score_adj, oom_adj,
> +						task_pid_nr(task), task->comm);
> +				p->signal->oom_score_adj = oom_adj;

Personally I like this change.

And. I think after this change we can actually move ->oom_score_adj into mm_struct,
but lets discuss this later.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
