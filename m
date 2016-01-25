Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id BE7876B0005
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 13:53:42 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id 65so86146471pff.2
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 10:53:42 -0800 (PST)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id wg10si581845pac.23.2016.01.25.10.53.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 10:53:42 -0800 (PST)
Received: by mail-pa0-x243.google.com with SMTP id a20so6906399pag.3
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 10:53:42 -0800 (PST)
Date: Mon, 25 Jan 2016 13:53:39 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v4 04/22] kthread: Add create_kthread_worker*()
Message-ID: <20160125185339.GB3628@mtj.duckdns.org>
References: <1453736711-6703-1-git-send-email-pmladek@suse.com>
 <1453736711-6703-5-git-send-email-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1453736711-6703-5-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Jan 25, 2016 at 04:44:53PM +0100, Petr Mladek wrote:
> +struct kthread_worker *
> +create_kthread_worker_on_cpu(int cpu, const char namefmt[])
> +{
> +	if (cpu < 0 || cpu > num_possible_cpus())
> +		return ERR_PTR(-EINVAL);

Comparing cpu ID to num_possible_cpus() doesn't make any sense.  It
should either be testing against cpu_possible_mask or testing against
nr_cpu_ids.  Does this test need to be in this function at all?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
