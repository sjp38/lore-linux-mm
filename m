Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1BF1B828E1
	for <linux-mm@kvack.org>; Wed, 29 Jun 2016 15:22:38 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id f89so130966713qtd.1
        for <linux-mm@kvack.org>; Wed, 29 Jun 2016 12:22:38 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v129si4061980qkc.105.2016.06.29.12.22.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jun 2016 12:22:37 -0700 (PDT)
Date: Wed, 29 Jun 2016 21:22:33 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mmotm: mm-oom-fortify-task_will_free_mem-fix
Message-ID: <20160629192232.GA19097@redhat.com>
References: <1467201562-6709-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1467201562-6709-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Vladimir Davydov <vdavydov@parallels.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 06/29, Michal Hocko wrote:
>
> But it seems that further changes I am
> planning in this area will benefit from stable task->mm in this path

Oh, so I hope you will cleanup this later,

> Just pull the task->mm !=
> NULL check inside the function.

OK, but this means it will always return false if the task is a zombie
leader.

I am not really arguing and this is not that bad, but this doesn't look
nice and imo asks for cleanup.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
