Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 730666B03A1
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 13:20:44 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id s69so23242309ioi.11
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 10:20:44 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id i143si3781810itb.35.2017.04.19.10.20.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Apr 2017 10:20:25 -0700 (PDT)
Date: Wed, 19 Apr 2017 19:20:19 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v6 05/15] lockdep: Implement crossrelease feature
Message-ID: <20170419172019.rohvxmtdalas6g57@hirez.programming.kicks-ass.net>
References: <1489479542-27030-1-git-send-email-byungchul.park@lge.com>
 <1489479542-27030-6-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1489479542-27030-6-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Tue, Mar 14, 2017 at 05:18:52PM +0900, Byungchul Park wrote:
> +config LOCKDEP_CROSSRELEASE
> +	bool "Lock debugging: make lockdep work for crosslocks"
> +	select PROVE_LOCKING

	depends PROVE_LOCKING

instead ?

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
> -- 
> 1.9.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
