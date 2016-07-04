Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 225666B0005
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 05:21:46 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id a4so118154901lfa.1
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 02:21:46 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id uc7si2375569wjc.248.2016.07.04.02.21.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jul 2016 02:21:44 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id 187so20191202wmz.1
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 02:21:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160704084347.GG898@swordfish>
References: <1467614999-4326-1-git-send-email-opensource.ganesh@gmail.com>
 <1467614999-4326-7-git-send-email-opensource.ganesh@gmail.com> <20160704084347.GG898@swordfish>
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Date: Mon, 4 Jul 2016 17:21:43 +0800
Message-ID: <CADAEsF91-j-DDXt63-dtG77Q5uowb8hdvT2Zk54B74XwDxFCxQ@mail.gmail.com>
Subject: Re: [PATCH v2 7/8] mm/zsmalloc: add __init,__exit attribute
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, rostedt@goodmis.org, mingo@redhat.com

Hi, Sergey

2016-07-04 16:43 GMT+08:00 Sergey Senozhatsky
<sergey.senozhatsky.work@gmail.com>:
> On (07/04/16 14:49), Ganesh Mahendran wrote:
> [..]
>> -static void zs_unregister_cpu_notifier(void)
>> +static void __exit zs_unregister_cpu_notifier(void)
>>  {
>
> this __exit symbol is called from `__init zs_init()' and thus is
> free to crash.

I change code to force the code goto notifier_fail where the
zs_unregister_cpu_notifier will be called.
I tested with zsmalloc module buildin and built as a module.

Please correct me, if I miss something.

Thanks.


>
>         -ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
