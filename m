Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 5338C9003C7
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 06:07:40 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so213791561wib.1
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 03:07:39 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gm12si12692155wjc.83.2015.07.29.03.07.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 29 Jul 2015 03:07:38 -0700 (PDT)
Date: Wed, 29 Jul 2015 12:07:37 +0200
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [RFC PATCH 06/14] kthread: Add kthread_worker_created()
Message-ID: <20150729100737.GJ2673@pathway.suse.cz>
References: <1438094371-8326-1-git-send-email-pmladek@suse.com>
 <1438094371-8326-7-git-send-email-pmladek@suse.com>
 <20150728172657.GC5322@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150728172657.GC5322@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 2015-07-28 13:26:57, Tejun Heo wrote:
> Hello,
> 
> On Tue, Jul 28, 2015 at 04:39:23PM +0200, Petr Mladek wrote:
> > I would like to make cleaner kthread worker API and hide the definition
> > of struct kthread_worker. It will prevent any custom hacks and make
> > the API more secure.
> > 
> > This patch provides an API to check if the worker has been created
> > and hides the implementation details.
> 
> Maybe it'd be a better idea to make create_kthread_worker() allocate
> and return pointer to struct kthread_worker?  You're adding
> create/destroy interface anyway, it won't need a separate created
> query function and the synchronization rules would be self-evident.

Makes sense. I actually did it this way in one temporary version and reverted
it from some ugly reason.

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
