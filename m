Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 43A526B0038
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 15:19:33 -0400 (EDT)
Received: by igbni9 with SMTP id ni9so24145059igb.0
        for <linux-mm@kvack.org>; Fri, 18 Sep 2015 12:19:33 -0700 (PDT)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id z5si8265595igl.39.2015.09.18.12.19.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 18 Sep 2015 12:19:32 -0700 (PDT)
Date: Fri, 18 Sep 2015 14:19:29 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/oom_kill.c: don't kill TASK_UNINTERRUPTIBLE tasks
In-Reply-To: <20150918190725.GA24989@redhat.com>
Message-ID: <alpine.DEB.2.11.1509181417220.12714@east.gentwo.org>
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com> <20150917192204.GA2728@redhat.com> <alpine.DEB.2.11.1509181035180.11189@east.gentwo.org> <20150918162423.GA18136@redhat.com> <alpine.DEB.2.11.1509181200140.11964@east.gentwo.org>
 <20150918190725.GA24989@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Kyle Walker <kwalker@redhat.com>, akpm@linux-foundation.org, mhocko@suse.cz, rientjes@google.com, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Stanislav Kozina <skozina@redhat.com>

On Fri, 18 Sep 2015, Oleg Nesterov wrote:

> And btw. Yes, this is a bit off-topic, but I think another change make
> sense too. We should report the fact we are going to kill another task
> because the previous victim refuse to die, and print its stack trace.

What happens is that the previous victim did not enter exit processing. If
it would then it would be excluded by other checks. The first victim never
reacted and never started using the memory resources available for
exiting. Thats why I thought it maybe safe to go this way.

An issue could result from another process being terminated and the first
victim finally reacting to the signal and also beginning termination. Then
we have contention on the reserves.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
