Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8D2C86B0253
	for <linux-mm@kvack.org>; Mon,  2 May 2016 07:15:41 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id xm6so247636808pab.3
        for <linux-mm@kvack.org>; Mon, 02 May 2016 04:15:41 -0700 (PDT)
Received: from out4441.biz.mail.alibaba.com (out4441.biz.mail.alibaba.com. [47.88.44.41])
        by mx.google.com with ESMTP id p123si4578661pfb.235.2016.05.02.04.15.39
        for <linux-mm@kvack.org>;
        Mon, 02 May 2016 04:15:40 -0700 (PDT)
Message-ID: <572737FB.2020405@emindsoft.com.cn>
Date: Mon, 02 May 2016 19:20:27 +0800
From: Chen Gang <chengang@emindsoft.com.cn>
MIME-Version: 1.0
Subject: Re: [PATCH] include/linux/kasan.h: Notice about 0 for kasan_[dis/en]able_current()
References: <1462167348-6280-1-git-send-email-chengang@emindsoft.com.cn> <CAG_fn=W5Ai_cqhzyi=EBEyhhQtvoQtOsuyfBfRihf=fuKh2Xqw@mail.gmail.com>
In-Reply-To: <CAG_fn=W5Ai_cqhzyi=EBEyhhQtvoQtOsuyfBfRihf=fuKh2Xqw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dmitriy Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Chen Gang <gang.chen.5i5j@gmail.com>

On 5/2/16 18:49, Alexander Potapenko wrote:
> On Mon, May 2, 2016 at 7:35 AM,  <chengang@emindsoft.com.cn> wrote:
>>
>> According to their comments and the kasan_depth's initialization, if
>> kasan_depth is zero, it means disable. So kasan_depth need consider
>> about the 0 overflow.
>>
>> Also remove useless comments for dummy kasan_slab_free().
>>
>> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
> 
> Acked-by: Alexander Potapenko <glider@google.com>
> 

OK, thanks.

Another patch thread is also related with this patch thread, please help
check.

And sorry, originally, I did not let the 2 patches in one patches set.

Thanks.
-- 
Chen Gang (e??a??)

Managing Natural Environments is the Duty of Human Beings.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
