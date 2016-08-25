Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id E420483093
	for <linux-mm@kvack.org>; Thu, 25 Aug 2016 07:37:16 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 33so30254850lfw.1
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 04:37:16 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e5si13773561wmd.141.2016.08.25.04.37.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 Aug 2016 04:37:15 -0700 (PDT)
Date: Thu, 25 Aug 2016 13:37:08 +0200
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v6 20/20] thermal/intel_powerclamp: Convert the kthread
 to kthread worker API
Message-ID: <20160825113708.GH4866@pathway.suse.cz>
References: <1460646879-617-1-git-send-email-pmladek@suse.com>
 <1460646879-617-21-git-send-email-pmladek@suse.com>
 <20160825083316.myqbas7d6gtv62c6@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160825083316.myqbas7d6gtv62c6@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Zhang Rui <rui.zhang@intel.com>, Eduardo Valentin <edubezval@gmail.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-pm@vger.kernel.org

On Thu 2016-08-25 10:33:17, Sebastian Andrzej Siewior wrote:
> On 2016-04-14 17:14:39 [+0200], Petr Mladek wrote:
> > Kthreads are currently implemented as an infinite loop. Each
> > has its own variant of checks for terminating, freezing,
> > awakening. In many cases it is unclear to say in which state
> > it is and sometimes it is done a wrong way.
> 
> What is the status of this? This is the last email I received and it is
> from April.

There were still some discussions about the kthread worker API.
Anyway, the needed kthread API changes are in Andrew's -mm tree now
and will be hopefully included in 4.9.

I did not want to send the patches using the API before the API
changes are upstream. But I could send the two intel_powerclamp
patches now if you are comfortable with having them on top of
the -mm tree or linux-next.

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
