Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id BA1056B0032
	for <linux-mm@kvack.org>; Sat, 21 Sep 2013 15:20:15 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kp14so711378pab.20
        for <linux-mm@kvack.org>; Sat, 21 Sep 2013 12:20:15 -0700 (PDT)
Date: Sat, 21 Sep 2013 21:13:17 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20130921191317.GA15531@redhat.com>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de> <1378805550-29949-38-git-send-email-mgorman@suse.de> <20130917143003.GA29354@twins.programming.kicks-ass.net> <20130917162050.GK22421@suse.de> <20130917164505.GG12926@twins.programming.kicks-ass.net> <20130918154939.GZ26785@twins.programming.kicks-ass.net> <20130919143241.GB26785@twins.programming.kicks-ass.net> <20130921163404.GA8545@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130921163404.GA8545@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>

On 09/21, Oleg Nesterov wrote:
>
> As for the patch itself, I am not sure.

Forgot to mention... and with this patch cpu_hotplug_done() loses the
"release" semantics, not sure this is fine.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
