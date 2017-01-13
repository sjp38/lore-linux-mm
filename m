Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id DA08F6B0253
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 05:11:47 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 127so109829339pfg.5
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 02:11:47 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id f17si12250376pgg.308.2017.01.13.02.11.46
        for <linux-mm@kvack.org>;
        Fri, 13 Jan 2017 02:11:47 -0800 (PST)
Date: Fri, 13 Jan 2017 19:11:43 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v4 05/15] lockdep: Make check_prev_add can use a separate
 stack_trace
Message-ID: <20170113101143.GE3326@X58A-UD3R>
References: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
 <1481260331-360-6-git-send-email-byungchul.park@lge.com>
 <20170112161643.GB3144@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170112161643.GB3144@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

What do you think about the following patches doing it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
