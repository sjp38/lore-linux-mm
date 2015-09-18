Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 8D2306B0254
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 18:07:53 -0400 (EDT)
Received: by igbkq10 with SMTP id kq10so45489550igb.0
        for <linux-mm@kvack.org>; Fri, 18 Sep 2015 15:07:53 -0700 (PDT)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id jk10si161330igb.64.2015.09.18.15.07.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 18 Sep 2015 15:07:52 -0700 (PDT)
Date: Fri, 18 Sep 2015 17:07:49 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/oom_kill.c: don't kill TASK_UNINTERRUPTIBLE tasks
In-Reply-To: <CAEPKNT+H28BdJxb12MfFSrtoA8jkGX5WGSPGpH4ejRDbCQZFXQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.11.1509181704250.13660@east.gentwo.org>
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com> <20150917192204.GA2728@redhat.com> <alpine.DEB.2.11.1509181035180.11189@east.gentwo.org> <20150918162423.GA18136@redhat.com> <alpine.DEB.2.11.1509181200140.11964@east.gentwo.org>
 <20150918190725.GA24989@redhat.com> <alpine.DEB.2.11.1509181417220.12714@east.gentwo.org> <CAEPKNT+H28BdJxb12MfFSrtoA8jkGX5WGSPGpH4ejRDbCQZFXQ@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kyle Walker <kwalker@redhat.com>
Cc: Oleg Nesterov <oleg@redhat.com>, akpm@linux-foundation.org, mhocko@suse.cz, rientjes@google.com, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Stanislav Kozina <skozina@redhat.com>

On Fri, 18 Sep 2015, Kyle Walker wrote:

> I do like the idea of not stalling completely in an oom just because the
> first attempt didn't go so well. Is there any possibility of simply having
> our cake and eating it too? Specifically, omitting TASK_UNINTERRUPTIBLE
> tasks
> as low-hanging fruit and allowing the oom to continue in the event that the
> first attempt stalls?

TASK_UNINTERRUPTIBLE tasks should not be sleeping that long and they
*should react* in a reasonable timeframe. There is an alternative API for
those cases that cannot. Typically this is a write that is stalling. If we
kill the process then its pointless to wait on the write to complete. See

https://lwn.net/Articles/288056/

http://www.ibm.com/developerworks/library/l-task-killable/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
