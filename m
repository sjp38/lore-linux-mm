Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 736726B0031
	for <linux-mm@kvack.org>; Thu,  3 Oct 2013 03:43:24 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id q10so2056585pdj.7
        for <linux-mm@kvack.org>; Thu, 03 Oct 2013 00:43:24 -0700 (PDT)
Date: Thu, 3 Oct 2013 09:43:01 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC] introduce synchronize_sched_{enter,exit}()
Message-ID: <20131003074301.GZ3081@twins.programming.kicks-ass.net>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
 <1378805550-29949-38-git-send-email-mgorman@suse.de>
 <20130917143003.GA29354@twins.programming.kicks-ass.net>
 <20130929183634.GA15563@redhat.com>
 <20131002144125.GS3081@twins.programming.kicks-ass.net>
 <20131003070459.GB5320@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131003070459.GB5320@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Thu, Oct 03, 2013 at 09:04:59AM +0200, Ingo Molnar wrote:
> 
> * Peter Zijlstra <peterz@infradead.org> wrote:
> 
> > 
> 
> Fully agreed! :-)

haha.. never realized I send that email completely empty. It was
supposed to contain the patch I later send as 2/3.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
