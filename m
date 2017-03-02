Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id F1DFE6B0387
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 08:41:05 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id x66so82347656pfb.2
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 05:41:05 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id c24si7493871pfd.129.2017.03.02.05.41.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 05:41:05 -0800 (PST)
Date: Thu, 2 Mar 2017 14:41:03 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v5 06/13] lockdep: Implement crossrelease feature
Message-ID: <20170302134103.GS6515@twins.programming.kicks-ass.net>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
 <1484745459-2055-7-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1484745459-2055-7-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Wed, Jan 18, 2017 at 10:17:32PM +0900, Byungchul Park wrote:
> diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
> index a6c8db1..7890661 100644
> --- a/lib/Kconfig.debug
> +++ b/lib/Kconfig.debug
> @@ -1042,6 +1042,19 @@ config DEBUG_LOCK_ALLOC
>  	 spin_lock_init()/mutex_init()/etc., or whether there is any lock
>  	 held during task exit.
>  
> +config LOCKDEP_CROSSRELEASE
> +	bool "Lock debugging: make lockdep work for crosslocks"
> +	select LOCKDEP
> +	select TRACE_IRQFLAGS
> +	default n
> +	help
> +	 This makes lockdep work for crosslock which is a lock allowed to
> +	 be released in a different context from the acquisition context.
> +	 Normally a lock must be released in the context acquiring the lock.
> +	 However, relexing this constraint helps synchronization primitives
> +	 such as page locks or completions can use the lock correctness
> +	 detector, lockdep.
> +
>  config PROVE_LOCKING
>  	bool "Lock debugging: prove locking correctness"
>  	depends on DEBUG_KERNEL && TRACE_IRQFLAGS_SUPPORT && STACKTRACE_SUPPORT && LOCKDEP_SUPPORT


Does CROSSRELEASE && !PROVE_LOCKING make any sense?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
