Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 191C46B025F
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 10:05:42 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b83so63591597pfl.6
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 07:05:42 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id e16si2803539pli.913.2017.08.09.07.05.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Aug 2017 07:05:40 -0700 (PDT)
Date: Wed, 9 Aug 2017 16:05:35 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v8 05/14] lockdep: Implement crossrelease feature
Message-ID: <20170809140535.aerk2ivnf4kv2mgf@hirez.programming.kicks-ass.net>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
 <1502089981-21272-6-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1502089981-21272-6-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Mon, Aug 07, 2017 at 04:12:52PM +0900, Byungchul Park wrote:
> diff --git a/include/linux/lockdep.h b/include/linux/lockdep.h
> index fffe49f..0c8a1b8 100644
> --- a/include/linux/lockdep.h
> +++ b/include/linux/lockdep.h
> @@ -467,6 +520,49 @@ static inline void lockdep_on(void)
>  
>  #endif /* !LOCKDEP */
>  
> +enum context_t {
> +	HARD,
> +	SOFT,
> +	PROC,
> +	CONTEXT_NR,
> +};

Since this is the global namespace and those being somewhat generic
names, I've renamed the lot:

+enum xhlock_context_t {
+       XHLOCK_HARD,
+       XHLOCK_SOFT,
+       XHLOCK_PROC,
+       XHLOCK_NR,
+};

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
