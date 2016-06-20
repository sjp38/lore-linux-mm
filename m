Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id E82EC6B0005
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 16:27:41 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id l81so406984626qke.3
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 13:27:41 -0700 (PDT)
Received: from mail-yw0-x242.google.com (mail-yw0-x242.google.com. [2607:f8b0:4002:c05::242])
        by mx.google.com with ESMTPS id o79si8893626yba.270.2016.06.20.13.27.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jun 2016 13:27:41 -0700 (PDT)
Received: by mail-yw0-x242.google.com with SMTP id i12so2900400ywa.0
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 13:27:41 -0700 (PDT)
Date: Mon, 20 Jun 2016 16:27:39 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v9 10/12] kthread: Allow to cancel kthread work
Message-ID: <20160620202739.GB3262@mtj.duckdns.org>
References: <1466075851-24013-1-git-send-email-pmladek@suse.com>
 <1466075851-24013-11-git-send-email-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1466075851-24013-11-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Jun 16, 2016 at 01:17:29PM +0200, Petr Mladek wrote:
> +/*
> + * Returns true when the work could not be queued at the moment.
> + * It happens when it is already pending in a worker list
> + * or when it is being cancelled.
> + *
> + * This function must be called under work->worker->lock.

Replace the comment with a lockdep assertion?

> + */
> +static inline bool queuing_blocked(const struct kthread_work *work)
> +{
> +	return !list_empty(&work->node) || work->canceling;
> +}

Other than that,

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
