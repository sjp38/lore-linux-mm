Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f176.google.com (mail-yk0-f176.google.com [209.85.160.176])
	by kanga.kvack.org (Postfix) with ESMTP id 173D06B0005
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 11:08:05 -0500 (EST)
Received: by mail-yk0-f176.google.com with SMTP id z13so74928536ykd.0
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 08:08:05 -0800 (PST)
Received: from mail-yk0-x234.google.com (mail-yk0-x234.google.com. [2607:f8b0:4002:c07::234])
        by mx.google.com with ESMTPS id 62si14779747ybt.168.2016.02.16.08.08.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Feb 2016 08:08:04 -0800 (PST)
Received: by mail-yk0-x234.google.com with SMTP id z7so74859663yka.3
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 08:08:04 -0800 (PST)
Date: Tue, 16 Feb 2016 11:08:01 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v4 04/22] kthread: Add create_kthread_worker*()
Message-ID: <20160216160801.GM3741@mtj.duckdns.org>
References: <1453736711-6703-1-git-send-email-pmladek@suse.com>
 <1453736711-6703-5-git-send-email-pmladek@suse.com>
 <20160125185339.GB3628@mtj.duckdns.org>
 <20160216154443.GW12548@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160216154443.GW12548@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

Hello,

On Tue, Feb 16, 2016 at 04:44:43PM +0100, Petr Mladek wrote:
> I wanted to be sure. The cpu number is later passed to
> cpu_to_node(cpu) in kthread_create_on_cpu().
> 
> I am going to replace this with a check against nr_cpu_ids in
> kthread_create_on_cpu() which makes more sense.
> 
> I might be too paranoid. But this is slow path. People
> do mistakes...

idk, that just ended up adding a subtly broken code which checks for
an unlikely condition which would cause a crash anyway.  I don't see
the point.  If you want to insist on it, please at least make it a
WARN_ON().  It's a clear kernel bug.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
