Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id C14246B0069
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 11:38:17 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id s36so353130761otd.3
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 08:38:17 -0800 (PST)
Received: from mail-oi0-x241.google.com (mail-oi0-x241.google.com. [2607:f8b0:4003:c06::241])
        by mx.google.com with ESMTPS id h19si8309677otc.281.2017.02.01.08.38.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Feb 2017 08:38:17 -0800 (PST)
Received: by mail-oi0-x241.google.com with SMTP id w144so31265738oiw.1
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 08:38:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170201163426.2287910-1-arnd@arndb.de>
References: <20170201163426.2287910-1-arnd@arndb.de>
From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 1 Feb 2017 17:38:16 +0100
Message-ID: <CAK8P3a0uo5gpDJ-u6OeG4rAXg+BaXcz7CVcY9rR=n826m=2XMQ@mail.gmail.com>
Subject: Re: [PATCH] [RFC] sched: make DECLARE_COMPLETION_ONSTACK() work with clang
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@elte.hu>

On Wed, Feb 1, 2017 at 5:34 PM, Arnd Bergmann <arnd@arndb.de> wrote:

> diff --git a/include/linux/completion.h b/include/linux/completion.h
> index fa5d3efaba56..5d5aaae3af43 100644
> --- a/include/linux/completion.h
> +++ b/include/linux/completion.h
> @@ -31,7 +31,7 @@ struct completion {
>         { 0, __WAIT_QUEUE_HEAD_INITIALIZER((work).wait) }
>
>  #define COMPLETION_INITIALIZER_ONSTACK(work) \
> -       (*init_completion(&work))
> +       ({ init_completion(&work); work; })
>
>  /**
>   * DECLARE_COMPLETION - declare and initialize a completion structure
> @@ -70,11 +70,10 @@ struct completion {
>   * This inline function will initialize a dynamically created completion
>   * structure.
>   */
> -static inline struct completion *init_completion(struct completion *x)
> +static inline void init_completion(struct completion *x)
>  {
>         x->done = 0;
>         init_waitqueue_head(&x->wait);
> -       return x;
>  }
>

I accidentally submitted the wrong patch, this is the revert of the
actual change.

       Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
