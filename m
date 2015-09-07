Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id E75DF6B0038
	for <linux-mm@kvack.org>; Mon,  7 Sep 2015 13:52:03 -0400 (EDT)
Received: by qgev79 with SMTP id v79so66131074qge.0
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 10:52:03 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 143si593615qhy.11.2015.09.07.10.52.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Sep 2015 10:52:02 -0700 (PDT)
Date: Mon, 7 Sep 2015 19:49:14 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC PATCH 10/14] ring_buffer: Fix more races when terminating
	the producer in the benchmark
Message-ID: <20150907174914.GA2148@redhat.com>
References: <1438094371-8326-1-git-send-email-pmladek@suse.com> <1438094371-8326-11-git-send-email-pmladek@suse.com> <20150803143323.426ea2fc@gandalf.local.home> <20150904093856.GI22739@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150904093856.GI22739@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

Sorry, I didn't read these emails, and I never looked at this code...
Can't understand what are you talking about but a minor nit anyway ;)

On 09/04, Petr Mladek wrote:
>
> +	__set_current_state(TASK_RUNNING);
>  	if (!kthread_should_stop())
>  		wait_to_die();

I bet this wait_to_die() can die, consumer/producer can simply exit.

Just you need get_task_struct() after kthread_create(), and put_task_struct()
after kthread_stop().

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
