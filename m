Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id C4B436B0005
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 11:09:23 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id g62so36870924wme.0
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 08:09:23 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y81si4993154wmb.54.2016.02.24.08.09.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 Feb 2016 08:09:22 -0800 (PST)
Date: Wed, 24 Feb 2016 17:09:21 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v5 07/20] kthread: Initial support for delayed kthread
 work
Message-ID: <20160224160921.GA3305@pathway.suse.cz>
References: <1456153030-12400-8-git-send-email-pmladek@suse.com>
 <201602230028.qy3AtO8V%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201602230028.qy3AtO8V%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 2016-02-23 00:06:50, kbuild test robot wrote:
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
> >> kernel/kthread.c:833: warning: No description found for parameter 'dwork'
> >> kernel/kthread.c:833: warning: No description found for parameter 'delay'
> >> kernel/kthread.c:833: warning: Excess function parameter 'work' description in 'queue_delayed_kthread_work'
>    kernel/sys.c:1: warning: no structured comments found

Great catch. Please, find below a fixed version of the patch.
