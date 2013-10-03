Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id A2BFB6B0031
	for <linux-mm@kvack.org>; Thu,  3 Oct 2013 03:05:07 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id un15so2043481pbc.15
        for <linux-mm@kvack.org>; Thu, 03 Oct 2013 00:05:07 -0700 (PDT)
Received: by mail-ee0-f53.google.com with SMTP id b15so873967eek.40
        for <linux-mm@kvack.org>; Thu, 03 Oct 2013 00:05:02 -0700 (PDT)
Date: Thu, 3 Oct 2013 09:04:59 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC] introduce synchronize_sched_{enter,exit}()
Message-ID: <20131003070459.GB5320@gmail.com>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
 <1378805550-29949-38-git-send-email-mgorman@suse.de>
 <20130917143003.GA29354@twins.programming.kicks-ass.net>
 <20130929183634.GA15563@redhat.com>
 <20131002144125.GS3081@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131002144125.GS3081@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>, Linus Torvalds <torvalds@linux-foundation.org>


* Peter Zijlstra <peterz@infradead.org> wrote:

> 

Fully agreed! :-)

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
