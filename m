Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 213B96B03A0
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 05:58:58 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id g22so11907756vke.22
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 02:58:58 -0700 (PDT)
Received: from mail-vk0-x236.google.com (mail-vk0-x236.google.com. [2607:f8b0:400c:c05::236])
        by mx.google.com with ESMTPS id t193si1481258vkc.63.2017.03.28.02.58.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 02:58:57 -0700 (PDT)
Received: by mail-vk0-x236.google.com with SMTP id d188so81737061vka.0
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 02:58:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAC5umyhuez=F1BQax=tos+5cKpE8rQ5hFc_eQGwP51mNpZ84rw@mail.gmail.com>
References: <20170321091805.140676-1-dvyukov@google.com> <CAC5umyhuez=F1BQax=tos+5cKpE8rQ5hFc_eQGwP51mNpZ84rw@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 28 Mar 2017 11:58:36 +0200
Message-ID: <CACT4Y+Z1dGhUBqb2BuSQdkCOWVFqWw_5zDtXUe3yYdrQ_42giA@mail.gmail.com>
Subject: Re: [PATCH] fault-inject: use correct check for interrupts
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sat, Mar 25, 2017 at 8:18 AM, Akinobu Mita <akinobu.mita@gmail.com> wrote:
> 2017-03-21 18:18 GMT+09:00 Dmitry Vyukov <dvyukov@google.com>:
>> in_interrupt() also returns true when bh is disabled in task context.
>> That's not what fail_task() wants to check.
>> Use the new in_task() predicate that does the right thing.
>>
>> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
>> Cc: akinobu.mita@gmail.com
>> Cc: linux-kernel@vger.kernel.org
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: linux-mm@kvack.org
>
> This change looks good to me.
>
> Reviewed-by: Akinobu Mita <akinobu.mita@gmail.com>


Andrew, will you take this to mm please?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
