Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f182.google.com (mail-yk0-f182.google.com [209.85.160.182])
	by kanga.kvack.org (Postfix) with ESMTP id 6C9AE6B0253
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 13:41:57 -0400 (EDT)
Received: by ykdu72 with SMTP id u72so101934875ykd.2
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 10:41:57 -0700 (PDT)
Received: from mail-yk0-x22a.google.com (mail-yk0-x22a.google.com. [2607:f8b0:4002:c07::22a])
        by mx.google.com with ESMTPS id 191si16023356yky.111.2015.07.28.10.41.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Jul 2015 10:41:56 -0700 (PDT)
Received: by ykdu72 with SMTP id u72so101934631ykd.2
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 10:41:56 -0700 (PDT)
Date: Tue, 28 Jul 2015 13:41:54 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH 14/14] kthread_worker: Add
 set_kthread_worker_scheduler*()
Message-ID: <20150728174154.GG5322@mtj.duckdns.org>
References: <1438094371-8326-1-git-send-email-pmladek@suse.com>
 <1438094371-8326-15-git-send-email-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1438094371-8326-15-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Jul 28, 2015 at 04:39:31PM +0200, Petr Mladek wrote:
> +/**
> + * set_kthread_worker_scheduler - change the scheduling policy and/or RT
> + *	priority of a kthread worker.
> + * @worker: target kthread_worker
> + * @policy: new policy
> + * @sched_priority: new RT priority
> + *
> + * Return: 0 on success. An error code otherwise.
> + */
> +int set_kthread_worker_scheduler(struct kthread_worker *worker,
> +				 int policy, int sched_priority)
> +{
> +	return __set_kthread_worker_scheduler(worker, policy, sched_priority,
> +					      true);
> +}

Ditto.  I don't get why we would want these thin wrappers.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
