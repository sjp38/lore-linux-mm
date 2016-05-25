Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id D1C066B0266
	for <linux-mm@kvack.org>; Wed, 25 May 2016 16:42:05 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id 82so102765210ior.0
        for <linux-mm@kvack.org>; Wed, 25 May 2016 13:42:05 -0700 (PDT)
Received: from mail-it0-x244.google.com (mail-it0-x244.google.com. [2607:f8b0:4001:c0b::244])
        by mx.google.com with ESMTPS id y71si6822075oia.24.2016.05.25.13.42.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 May 2016 13:42:05 -0700 (PDT)
Received: by mail-it0-x244.google.com with SMTP id l63so6799061ita.0
        for <linux-mm@kvack.org>; Wed, 25 May 2016 13:42:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160511105224.GE2749@pathway.suse.cz>
References: <1460646879-617-1-git-send-email-pmladek@suse.com>
	<20160422183040.GW7822@mtj.duckdns.org>
	<20160511105224.GE2749@pathway.suse.cz>
Date: Wed, 25 May 2016 16:42:04 -0400
Message-ID: <CAOS58YP101zopOfTSUYNRN4Jk3Ts_47+DFXVam0KGbr8OtaF4g@mail.gmail.com>
Subject: Re: [PATCH v6 00/20] kthread: Use kthread worker API more widely
From: Tejun Heo <tj@kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>, Linux API <linux-api@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, linux-watchdog@vger.kernel.org, Corey Minyard <minyard@acm.org>, openipmi-developer@lists.sourceforge.net, Doug Ledford <dledford@redhat.com>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, linux-rdma@vger.kernel.org, Maxim Levitsky <maximlevitsky@gmail.com>, Zhang Rui <rui.zhang@intel.com>, Eduardo Valentin <edubezval@gmail.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, "linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>

On Wed, May 11, 2016 at 6:52 AM, Petr Mladek <pmladek@suse.com> wrote:
> Tejun, may I add your ack for some of the patches, please?
> Or do you want to wait for the resend?

When you repost, I'll explicitly ack the patches.

Thanks!

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
