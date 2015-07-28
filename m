Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f172.google.com (mail-yk0-f172.google.com [209.85.160.172])
	by kanga.kvack.org (Postfix) with ESMTP id 096C16B0038
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 13:27:02 -0400 (EDT)
Received: by ykax123 with SMTP id x123so101784809yka.1
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 10:27:01 -0700 (PDT)
Received: from mail-yk0-x243.google.com (mail-yk0-x243.google.com. [2607:f8b0:4002:c07::243])
        by mx.google.com with ESMTPS id a63si16014460ykd.11.2015.07.28.10.27.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Jul 2015 10:27:00 -0700 (PDT)
Received: by ykdu72 with SMTP id u72so6275565ykd.3
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 10:27:00 -0700 (PDT)
Date: Tue, 28 Jul 2015 13:26:57 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH 06/14] kthread: Add kthread_worker_created()
Message-ID: <20150728172657.GC5322@mtj.duckdns.org>
References: <1438094371-8326-1-git-send-email-pmladek@suse.com>
 <1438094371-8326-7-git-send-email-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1438094371-8326-7-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

Hello,

On Tue, Jul 28, 2015 at 04:39:23PM +0200, Petr Mladek wrote:
> I would like to make cleaner kthread worker API and hide the definition
> of struct kthread_worker. It will prevent any custom hacks and make
> the API more secure.
> 
> This patch provides an API to check if the worker has been created
> and hides the implementation details.

Maybe it'd be a better idea to make create_kthread_worker() allocate
and return pointer to struct kthread_worker?  You're adding
create/destroy interface anyway, it won't need a separate created
query function and the synchronization rules would be self-evident.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
