Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E9058440D03
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 02:30:58 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id n37so4453648wrb.17
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 23:30:58 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y144sor188651wmd.5.2017.11.09.23.30.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 Nov 2017 23:30:56 -0800 (PST)
Date: Fri, 10 Nov 2017 08:30:53 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v2] locking/lockdep: Revise
 Documentation/locking/crossrelease.txt
Message-ID: <20171110073053.qh4nhpl26i47gbiv@gmail.com>
References: <1510212036-22008-1-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1510212036-22008-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: peterz@infradead.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, kernel-team@lge.com


* Byungchul Park <byungchul.park@lge.com> wrote:

>     Event C depends on event A.
>     Event A depends on event B.
>     Event B depends on event C.
>  
> -   NOTE: Precisely speaking, a dependency is one between whether a
> -   waiter for an event can be woken up and whether another waiter for
> -   another event can be woken up. However from now on, we will describe
> -   a dependency as if it's one between an event and another event for
> -   simplicity.

Why was this explanation removed?

> -Lockdep tries to detect a deadlock by checking dependencies created by
> -lock operations, acquire and release. Waiting for a lock corresponds to
> -waiting for an event, and releasing a lock corresponds to triggering an
> -event in the previous section.
> +Lockdep tries to detect a deadlock by checking circular dependencies
> +created by lock operations, acquire and release, which are wait and
> +event respectively.

What? You changed a readable paragraph into an unreadable one.

Sorry, this text needs to be acked by someone with good English skills, and I 
don't have the time right now to fix it all up. Please send minimal, obvious
typo/grammar fixes only.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
