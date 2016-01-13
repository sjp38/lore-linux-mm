Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 18385828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 12:54:01 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id cy9so361923178pac.0
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 09:54:01 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id 63si3266789pfi.202.2016.01.13.09.54.00
        for <linux-mm@kvack.org>;
        Wed, 13 Jan 2016 09:54:00 -0800 (PST)
Date: Wed, 13 Jan 2016 09:53:53 -0800
From: Jacob Pan <jacob.jun.pan@linux.intel.com>
Subject: Re: [PATCH v3 22/22] thermal/intel_powerclamp: Convert the kthread
 to kthread worker API
Message-ID: <20160113095353.5231c28f@yairi>
In-Reply-To: <20160113101831.GQ731@pathway.suse.cz>
References: <1447853127-3461-1-git-send-email-pmladek@suse.com>
	<1447853127-3461-23-git-send-email-pmladek@suse.com>
	<20160107115531.34279a9b@icelake>
	<20160108164931.GT3178@pathway.suse.cz>
	<20160111181718.0ace4a58@yairi>
	<20160112101129.GN731@pathway.suse.cz>
	<20160112082021.6a28dc66@icelake>
	<20160113101831.GQ731@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, Zhang Rui <rui.zhang@intel.com>, Eduardo Valentin <edubezval@gmail.com>, linux-pm@vger.kernel.org, jacob.jun.pan@linux.intel.com

On Wed, 13 Jan 2016 11:18:31 +0100
Petr Mladek <pmladek@suse.com> wrote:

> > unsigned int __read_mostly freeze_timeout_msecs = 20 *
> > MSEC_PER_SEC;  
> 
> You are right. And it does not make sense to add an extra
> freezer-specific code if not really necessary.
> 
> Otherwise, I will keep the conversion into the kthread worker as is
> for now. Please, let me know if you are strongly against the split
> into the two works.
I am fine with the split now.

Another question, are you planning to convert acpi_pad.c as well? It
uses kthread similar way.


Jacob


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
