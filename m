Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id DA4A06B02E5
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 18:40:03 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id p66so123035430pga.4
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 15:40:03 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q14si28617982pgn.274.2016.11.15.15.40.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 15:40:03 -0800 (PST)
Date: Tue, 15 Nov 2016 15:40:02 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] kasan: support use-after-scope detection
Message-Id: <20161115154002.0c4c7a5e1fd23f12474fc80e@linux-foundation.org>
In-Reply-To: <1479226045-145148-1-git-send-email-dvyukov@google.com>
References: <1479226045-145148-1-git-send-email-dvyukov@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: aryabinin@virtuozzo.com, glider@google.com, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 15 Nov 2016 17:07:25 +0100 Dmitry Vyukov <dvyukov@google.com> wrote:

> Gcc revision 241896 implements use-after-scope detection.
> Will be available in gcc 7. Support it in KASAN.
> 
> Gcc emits 2 new callbacks to poison/unpoison large stack
> objects when they go in/out of scope.
> Implement the callbacks and add a test.
> 
> ...
>
> --- a/lib/test_kasan.c
> +++ b/lib/test_kasan.c
> @@ -411,6 +411,29 @@ static noinline void __init copy_user_test(void)
>  	kfree(kmem);
>  }
>  
> +static noinline void __init use_after_scope_test(void)

This reader has no idea why this code uses noinline, and I expect
others will have the same issue.

Can we please get a code comment in there to reveal the reason?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
