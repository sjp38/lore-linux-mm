Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id E61606B0255
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 16:32:27 -0400 (EDT)
Received: by ykdt18 with SMTP id t18so21983529ykd.3
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 13:32:27 -0700 (PDT)
Received: from mail-yk0-x22c.google.com (mail-yk0-x22c.google.com. [2607:f8b0:4002:c07::22c])
        by mx.google.com with ESMTPS id a130si2086287ywc.89.2015.09.22.13.32.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 13:32:27 -0700 (PDT)
Received: by ykdg206 with SMTP id g206so21994520ykd.1
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 13:32:27 -0700 (PDT)
Date: Tue, 22 Sep 2015 16:32:22 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC v2 00/18] kthread: Use kthread worker API more widely
Message-ID: <20150922203222.GH17659@mtj.duckdns.org>
References: <1442840639-6963-1-git-send-email-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1442840639-6963-1-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

Hello, Petr.

On Mon, Sep 21, 2015 at 03:03:41PM +0200, Petr Mladek wrote:
> 9th, 12th, 17th patches: convert three kthreads into the new API,
>      namely: khugepaged, ring buffer benchmark, RCU gp kthreads[*]

I haven't gone through each conversion in detail but they generally
look good to me.

Thanks a lot for doing this!

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
