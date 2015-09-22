Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id 58FDA6B0253
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 14:20:55 -0400 (EDT)
Received: by ykdt18 with SMTP id t18so18141245ykd.3
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 11:20:55 -0700 (PDT)
Received: from mail-yk0-x22d.google.com (mail-yk0-x22d.google.com. [2607:f8b0:4002:c07::22d])
        by mx.google.com with ESMTPS id t5si1784101ykb.147.2015.09.22.11.20.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 11:20:54 -0700 (PDT)
Received: by ykdz138 with SMTP id z138so18108302ykd.2
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 11:20:54 -0700 (PDT)
Date: Tue, 22 Sep 2015 14:20:49 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC v2 02/18] kthread: Add create_kthread_worker*()
Message-ID: <20150922182049.GA17659@mtj.duckdns.org>
References: <1442840639-6963-1-git-send-email-pmladek@suse.com>
 <1442840639-6963-3-git-send-email-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442840639-6963-3-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

Hello, Petr.

On Mon, Sep 21, 2015 at 03:03:43PM +0200, Petr Mladek wrote:
> It enforces using kthread_worker_fn() for the main thread. But I doubt
> that there are any plans to create any alternative. In fact, I think
> that we do not want any alternative main thread because it would be
> hard to support consistency with the rest of the kthread worker API.

The original intention was allowing users to use a wrapper function
which sets up kthread attributes and then calls kthread_worker_fn().
That can be done by a work item too but is more cumbersome.  Just
wanted to note that.  Will keep reading on.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
