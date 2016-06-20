Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f71.google.com (mail-qg0-f71.google.com [209.85.192.71])
	by kanga.kvack.org (Postfix) with ESMTP id 540D96B0005
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 15:51:47 -0400 (EDT)
Received: by mail-qg0-f71.google.com with SMTP id a95so337148069qgf.2
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 12:51:47 -0700 (PDT)
Received: from mail-yw0-x242.google.com (mail-yw0-x242.google.com. [2607:f8b0:4002:c05::242])
        by mx.google.com with ESMTPS id n130si19837756ywn.41.2016.06.20.12.51.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Jun 2016 12:51:46 -0700 (PDT)
Received: by mail-yw0-x242.google.com with SMTP id f75so3583088ywb.3
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 12:51:46 -0700 (PDT)
Date: Mon, 20 Jun 2016 15:51:44 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v9 04/12] kthread: Allow to call
 __kthread_create_on_node() with va_list args
Message-ID: <20160620195144.GV3262@mtj.duckdns.org>
References: <1466075851-24013-1-git-send-email-pmladek@suse.com>
 <1466075851-24013-5-git-send-email-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1466075851-24013-5-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Jun 16, 2016 at 01:17:23PM +0200, Petr Mladek wrote:
> kthread_create_on_node() implements a bunch of logic to create
> the kthread. It is already called by kthread_create_on_cpu().
> 
> We are going to extend the kthread worker API and will
> need to call kthread_create_on_node() with va_list args there.
> 
> This patch does only a refactoring and does not modify the existing
> behavior.
> 
> Signed-off-by: Petr Mladek <pmladek@suse.com>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
