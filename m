Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 103006B0038
	for <linux-mm@kvack.org>; Sat, 25 Mar 2017 03:19:12 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e1so12118699pfd.9
        for <linux-mm@kvack.org>; Sat, 25 Mar 2017 00:19:12 -0700 (PDT)
Received: from mail-pg0-x230.google.com (mail-pg0-x230.google.com. [2607:f8b0:400e:c05::230])
        by mx.google.com with ESMTPS id 10si5580834pgb.197.2017.03.25.00.19.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 25 Mar 2017 00:19:11 -0700 (PDT)
Received: by mail-pg0-x230.google.com with SMTP id g2so5473900pge.3
        for <linux-mm@kvack.org>; Sat, 25 Mar 2017 00:19:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170321091805.140676-1-dvyukov@google.com>
References: <20170321091805.140676-1-dvyukov@google.com>
From: Akinobu Mita <akinobu.mita@gmail.com>
Date: Sat, 25 Mar 2017 16:18:50 +0900
Message-ID: <CAC5umyhuez=F1BQax=tos+5cKpE8rQ5hFc_eQGwP51mNpZ84rw@mail.gmail.com>
Subject: Re: [PATCH] fault-inject: use correct check for interrupts
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

2017-03-21 18:18 GMT+09:00 Dmitry Vyukov <dvyukov@google.com>:
> in_interrupt() also returns true when bh is disabled in task context.
> That's not what fail_task() wants to check.
> Use the new in_task() predicate that does the right thing.
>
> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: akinobu.mita@gmail.com
> Cc: linux-kernel@vger.kernel.org
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: linux-mm@kvack.org

This change looks good to me.

Reviewed-by: Akinobu Mita <akinobu.mita@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
