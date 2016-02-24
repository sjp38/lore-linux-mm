Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 2F20F6B0253
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 11:18:08 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id g62so11419735wme.0
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 08:18:08 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w9si4401284wja.96.2016.02.24.08.18.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 Feb 2016 08:18:06 -0800 (PST)
Date: Wed, 24 Feb 2016 17:18:05 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v5 08/20] kthread: Allow to cancel kthread work
Message-ID: <20160224161805.GB3305@pathway.suse.cz>
References: <1456153030-12400-9-git-send-email-pmladek@suse.com>
 <201602230025.uuCAc4Tn%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201602230025.uuCAc4Tn%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 2016-02-23 00:50:22, kbuild test robot wrote:
> Hi Petr,
> 
> [auto build test WARNING on soc-thermal/next]
> [also build test WARNING on v4.5-rc5 next-20160222]
> [if your patch is applied to the wrong git tree, please drop us a note to help improving the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Petr-Mladek/kthread-Use-kthread-worker-API-more-widely/20160222-230250
> base:   https://git.kernel.org/pub/scm/linux/kernel/git/evalenti/linux-soc-thermal next
> reproduce: make htmldocs
> 
> All warnings (new ones prefixed by >>):
> 
>    include/linux/init.h:1: warning: no structured comments found
>    kernel/kthread.c:860: warning: No description found for parameter 'dwork'
>    kernel/kthread.c:860: warning: No description found for parameter 'delay'
>    kernel/kthread.c:860: warning: Excess function parameter 'work' description in 'queue_delayed_kthread_work'
> >> kernel/kthread.c:1012: warning: bad line: 
>    kernel/sys.c:1: warning: no structured comments found
>    drivers/dma-buf/seqno-fence.c:1: warning: no structured comments found

> vim +1012 kernel/kthread.c
>   1001	
>   1002	/**
>   1003	 * cancel_kthread_work_sync - cancel a kthread work and wait for it to finish
>   1004	 * @work: the kthread work to cancel
>   1005	 *
>   1006	 * Cancel @work and wait for its execution to finish.  This function
>   1007	 * can be used even if the work re-queues itself. On return from this
>   1008	 * function, @work is guaranteed to be not pending or executing on any CPU.
>   1009	 *
>   1010	 * cancel_kthread_work_sync(&delayed_work->work) must not be used for
>   1011	 * delayed_work's. Use cancel_delayed_kthread_work_sync() instead.
> > 1012	
>   1013	 * The caller must ensure that the worker on which @work was last
>   1014	 * queued can't be destroyed before this function returns.
>   1015	 *

Ups, there was missing an asterisk. Please, find the fixed patch
below.
