Message-ID: <3D3F4A2F.B1A9F379@zip.com.au>
Date: Wed, 24 Jul 2002 17:45:35 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] updated low-latency zap_page_range
References: <1027556975.927.1641.camel@sinai>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robert Love <rml@tech9.net>
Cc: torvalds@transmeta.com, riel@conectiva.com.br, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Robert Love wrote:
> 
> ...
> +static inline void cond_resched_lock(spinlock_t * lock)
> +{
> +       if (need_resched() && preempt_count() == 1) {
> +               _raw_spin_unlock(lock);
> +               preempt_enable_no_resched();
> +               __cond_resched();
> +               spin_lock(lock);
> +       }
> +}

Maybe I'm being thick.  How come a simple spin_unlock() in here
won't do the right thing?

And this won't _really_ compile to nothing with CONFIG_PREEMPT=n,
will it?  It just does nothing because preempt_count() is zero?


-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
