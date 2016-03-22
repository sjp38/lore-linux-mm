Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 444FF6B007E
	for <linux-mm@kvack.org>; Tue, 22 Mar 2016 08:23:51 -0400 (EDT)
Received: by mail-wm0-f42.google.com with SMTP id l68so189971595wml.0
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 05:23:51 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id g1si20161599wmg.53.2016.03.22.05.23.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Mar 2016 05:23:49 -0700 (PDT)
Date: Tue, 22 Mar 2016 13:23:45 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 1/9] sched: add schedule_timeout_idle()
Message-ID: <20160322122345.GN6344@twins.programming.kicks-ass.net>
References: <1458644426-22973-1-git-send-email-mhocko@kernel.org>
 <1458644426-22973-2-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1458644426-22973-2-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@elte.hu>

On Tue, Mar 22, 2016 at 12:00:18PM +0100, Michal Hocko wrote:

>  extern signed long schedule_timeout_interruptible(signed long timeout);
>  extern signed long schedule_timeout_killable(signed long timeout);
>  extern signed long schedule_timeout_uninterruptible(signed long timeout);
> +extern signed long schedule_timeout_idle(signed long timeout);

> +/*
> + * Like schedule_timeout_uninterruptible(), except this task will not contribute
> + * to load average.
> + */
> +signed long __sched schedule_timeout_idle(signed long timeout)
> +{
> +	__set_current_state(TASK_IDLE);
> +	return schedule_timeout(timeout);
> +}
> +EXPORT_SYMBOL(schedule_timeout_idle);

Yes we have 3 such other wrappers, but I've gotta ask: why? They seem
pretty pointless.

Why not kill the lot?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
