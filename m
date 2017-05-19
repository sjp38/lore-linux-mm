Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CB975831F4
	for <linux-mm@kvack.org>; Fri, 19 May 2017 04:10:37 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p74so50227417pfd.11
        for <linux-mm@kvack.org>; Fri, 19 May 2017 01:10:37 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id l62si7938219pgl.137.2017.05.19.01.10.36
        for <linux-mm@kvack.org>;
        Fri, 19 May 2017 01:10:36 -0700 (PDT)
Date: Fri, 19 May 2017 17:07:08 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v6 05/15] lockdep: Implement crossrelease feature
Message-ID: <20170519080708.GG28017@X58A-UD3R>
References: <1489479542-27030-1-git-send-email-byungchul.park@lge.com>
 <1489479542-27030-6-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
In-Reply-To: <1489479542-27030-6-git-send-email-byungchul.park@lge.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Tue, Mar 14, 2017 at 05:18:52PM +0900, Byungchul Park wrote:
> Lockdep is a runtime locking correctness validator that detects and
> reports a deadlock or its possibility by checking dependencies between
> locks. It's useful since it does not report just an actual deadlock but
> also the possibility of a deadlock that has not actually happened yet.
> That enables problems to be fixed before they affect real systems.
> 
> However, this facility is only applicable to typical locks, such as
> spinlocks and mutexes, which are normally released within the context in
> which they were acquired. However, synchronization primitives like page
> locks or completions, which are allowed to be released in any context,
> also create dependencies and can cause a deadlock. So lockdep should
> track these locks to do a better job. The 'crossrelease' implementation
> makes these primitives also be tracked.

Excuse me but I have a question...

Only for maskable irq, can I assume that hardirq are prevented within
hardirq context? I remember that nested interrupts were allowed in the
past but not recommanded. But what about now? I'm curious about the
overall direction of kernel and current status. It would be very
appriciated if you answer it.

Thank you.
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
