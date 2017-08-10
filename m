Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 83C7E6B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 05:21:50 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id i192so1543962pgc.11
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 02:21:50 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id v11si17269plg.187.2017.08.10.02.21.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 02:21:49 -0700 (PDT)
Date: Thu, 10 Aug 2017 11:21:45 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v8 05/14] lockdep: Implement crossrelease feature
Message-ID: <20170810092145.6avlhvepnneh3swm@hirez.programming.kicks-ass.net>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
 <1502089981-21272-6-git-send-email-byungchul.park@lge.com>
 <20170809140535.aerk2ivnf4kv2mgf@hirez.programming.kicks-ass.net>
 <20170810013054.GW20323@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170810013054.GW20323@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Thu, Aug 10, 2017 at 10:30:54AM +0900, Byungchul Park wrote:

> With a little feedback, it rather makes us a bit confused between
> XHLOCK_NR and MAX_XHLOCK_NR. what about the following?
> 
> +enum xhlock_context_t {
> +       XHLOCK_HARD,
> +       XHLOCK_SOFT,
> +       XHLOCK_PROC,
> +       XHLOCK_CXT_NR,
> +};
> 
> But it's trivial. I like yours, too.

grep -l "XHLOCK_NR" `quilt series` | while read file; do sed -i
's/XHLOCK_NR/XHLOCK_CTX_NR/g' $file; done

:-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
