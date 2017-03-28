Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 77C5C6B0390
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 17:33:06 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id n130so92673ita.15
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 14:33:06 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id n2si4517889itn.120.2017.03.28.14.33.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 14:33:05 -0700 (PDT)
Date: Tue, 28 Mar 2017 14:32:54 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 3/8] x86: use long long for 64-bit atomic ops
Message-ID: <20170328213254.GA12803@bombadil.infradead.org>
References: <cover.1490717337.git.dvyukov@google.com>
 <aa139aea58a0c57961a81edc8b76edda75c6560d.1490717337.git.dvyukov@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <aa139aea58a0c57961a81edc8b76edda75c6560d.1490717337.git.dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: mark.rutland@arm.com, peterz@infradead.org, mingo@redhat.com, akpm@linux-foundation.org, will.deacon@arm.com, aryabinin@virtuozzo.com, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org

On Tue, Mar 28, 2017 at 06:15:40PM +0200, Dmitry Vyukov wrote:
> @@ -193,12 +193,12 @@ static inline long atomic64_xchg(atomic64_t *v, long new)
>   * @a: the amount to add to v...
>   * @u: ...unless v is equal to u.
>   *
> - * Atomically adds @a to @v, so long as it was not @u.
> + * Atomically adds @a to @v, so long long as it was not @u.
>   * Returns the old value of @v.
>   */

That's a clbuttic mistake!

https://www.google.com/search?q=clbuttic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
