Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f171.google.com (mail-yk0-f171.google.com [209.85.160.171])
	by kanga.kvack.org (Postfix) with ESMTP id 871E16B0038
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 13:41:01 -0400 (EDT)
Received: by ykdu72 with SMTP id u72so101913144ykd.2
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 10:41:01 -0700 (PDT)
Received: from mail-yk0-x234.google.com (mail-yk0-x234.google.com. [2607:f8b0:4002:c07::234])
        by mx.google.com with ESMTPS id a12si16005440ykc.172.2015.07.28.10.41.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Jul 2015 10:41:00 -0700 (PDT)
Received: by ykay190 with SMTP id y190so101726986yka.3
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 10:41:00 -0700 (PDT)
Date: Tue, 28 Jul 2015 13:40:58 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH 13/14] kthread_worker: Add
 set_kthread_worker_user_nice()
Message-ID: <20150728174058.GF5322@mtj.duckdns.org>
References: <1438094371-8326-1-git-send-email-pmladek@suse.com>
 <1438094371-8326-14-git-send-email-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1438094371-8326-14-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Jul 28, 2015 at 04:39:30PM +0200, Petr Mladek wrote:
...
> +/*
> + * set_kthread_worker_user_nice - set scheduling priority for the kthread worker
> + * @worker: target kthread_worker
> + * @nice: niceness value
> + */
> +void set_kthread_worker_user_nice(struct kthread_worker *worker, long nice)
> +{
> +	struct task_struct *task = worker->task;
> +
> +	WARN_ON(!task);
> +	set_user_nice(task, nice);
> +}
> +EXPORT_SYMBOL(set_kthread_worker_user_nice);

kthread_worker is explcitly associated with a single kthread.  Why do
we want to create explicit wrappers for kthread operations?  This is
encapsulation for encapsulation's sake.  It doesn't buy us anything at
all.  Just let the user access the associated kthread and operate on
it.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
