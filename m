Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f176.google.com (mail-yk0-f176.google.com [209.85.160.176])
	by kanga.kvack.org (Postfix) with ESMTP id D63E14402F8
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 15:24:58 -0400 (EDT)
Received: by ykdt18 with SMTP id t18so120077656ykd.3
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 12:24:58 -0700 (PDT)
Received: from mail-yk0-x22b.google.com (mail-yk0-x22b.google.com. [2607:f8b0:4002:c07::22b])
        by mx.google.com with ESMTPS id z9si6175232ywb.9.2015.10.02.12.24.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Oct 2015 12:24:58 -0700 (PDT)
Received: by ykdt18 with SMTP id t18so120077368ykd.3
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 12:24:58 -0700 (PDT)
Date: Fri, 2 Oct 2015 15:24:53 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC v2 07/18] kthread: Allow to cancel kthread work
Message-ID: <20151002192453.GA7564@mtj.duckdns.org>
References: <1442840639-6963-1-git-send-email-pmladek@suse.com>
 <1442840639-6963-8-git-send-email-pmladek@suse.com>
 <20150922193513.GE17659@mtj.duckdns.org>
 <20150925112617.GA3122@pathway.suse.cz>
 <20150928170314.GF2589@mtj.duckdns.org>
 <20151002154336.GC3122@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151002154336.GC3122@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

Hello,

On Fri, Oct 02, 2015 at 05:43:36PM +0200, Petr Mladek wrote:
> IMHO, we need both locks. The worker manipulates more works and
> need its own lock. We need work-specific lock because the work
> might be assigned to different workers and we need to be sure
> that the operations are really serialized, e.g. queuing.

I don't think we need per-work lock.  Do we have such usage in kernel
at all?  If you're worried, let the first queueing record the worker
and trigger warning if someone tries to queue it anywhere else.  This
doesn't need to be full-on general like workqueue.  Let's make
reasonable trade-offs where possible.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
