Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1F40E6B025F
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 05:51:13 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id t80so60735880pgb.0
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 02:51:13 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id i12si2489194plk.616.2017.08.09.02.51.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Aug 2017 02:51:11 -0700 (PDT)
Date: Wed, 9 Aug 2017 11:51:07 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v8 09/14] lockdep: Apply crossrelease to completions
Message-ID: <20170809095107.2nzb4m4wq2p77ppb@hirez.programming.kicks-ass.net>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
 <1502089981-21272-10-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1502089981-21272-10-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Mon, Aug 07, 2017 at 04:12:56PM +0900, Byungchul Park wrote:
> +static inline void wait_for_completion(struct completion *x)
> +{
> +	complete_acquire(x);
> +	__wait_for_completion(x);
> +	complete_release(x);
> +}
> +
> +static inline void wait_for_completion_io(struct completion *x)
> +{
> +	complete_acquire(x);
> +	__wait_for_completion_io(x);
> +	complete_release(x);
> +}
> +
> +static inline int wait_for_completion_interruptible(struct completion *x)
> +{
> +	int ret;
> +	complete_acquire(x);
> +	ret = __wait_for_completion_interruptible(x);
> +	complete_release(x);
> +	return ret;
> +}
> +
> +static inline int wait_for_completion_killable(struct completion *x)
> +{
> +	int ret;
> +	complete_acquire(x);
> +	ret = __wait_for_completion_killable(x);
> +	complete_release(x);
> +	return ret;
> +}

I don't understand, why not change __wait_for_common() ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
