Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 9A30C6B0253
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 07:36:47 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id g62so25700853wme.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 04:36:47 -0800 (PST)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id j83si3851023wmj.84.2016.02.25.04.36.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 04:36:46 -0800 (PST)
Date: Thu, 25 Feb 2016 13:36:41 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v5 05/20] kthread: Add destroy_kthread_worker()
Message-ID: <20160225123641.GH6357@twins.programming.kicks-ass.net>
References: <1456153030-12400-1-git-send-email-pmladek@suse.com>
 <1456153030-12400-6-git-send-email-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1456153030-12400-6-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Feb 22, 2016 at 03:56:55PM +0100, Petr Mladek wrote:
> Also note that drain() correctly handles self-queuing works in compare
> with flush().

Nothing seems to prevent adding more work after drain() observes
list_empty().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
