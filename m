Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id 370216B0254
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 07:49:39 -0400 (EDT)
Received: by laeb10 with SMTP id b10so27051855lae.1
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 04:49:38 -0700 (PDT)
Received: from mail-la0-x234.google.com (mail-la0-x234.google.com. [2a00:1450:4010:c03::234])
        by mx.google.com with ESMTPS id aj7si22900639lbc.11.2015.09.03.04.49.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Sep 2015 04:49:38 -0700 (PDT)
Received: by lagj9 with SMTP id j9so27017091lag.2
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 04:49:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150902194019.GL22326@mtj.duckdns.org>
References: <CAAeHK+zUJ74Zn17=rOyxacHU18SgCfC6bsYW=6kCY5GXJBwGfQ@mail.gmail.com>
	<20150902194019.GL22326@mtj.duckdns.org>
Date: Thu, 3 Sep 2015 13:49:37 +0200
Message-ID: <CAAeHK+yZ_696uNf3XFObjCxiG_J3BYvfG_YSMaPEmjuyZdfOzw@mail.gmail.com>
Subject: Re: Use-after-free in page_cache_async_readahead
From: Andrey Konovalov <andreyknvl@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@fb.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, Kostya Serebryany <kcc@google.com>

On Wed, Sep 2, 2015 at 9:40 PM, Tejun Heo <tj@kernel.org> wrote:
> Hello, Andrey.

Hello Tejun,

> On Wed, Sep 02, 2015 at 01:08:52PM +0200, Andrey Konovalov wrote:
>> While running KASAN on 4.2 with Trinity I got the following report:
>>
>> ==================================================================
>> BUG: KASan: use after free in page_cache_async_readahead+0x2cb/0x3f0
>> at addr ffff880034bf6690
>> Read of size 8 by task sshd/2571
>> =============================================================================
>> BUG kmalloc-16 (Tainted: G        W      ): kasan: bad access detected
>> -----------------------------------------------------------------------------
>>
>> Disabling lock debugging due to kernel taint
>> INFO: Allocated in bdi_init+0x168/0x960 age=554826 cpu=0 pid=6
>
> Can you please verify that the following patch fixes the issue?

I've hit this bug only twice during 24 hours of fuzzing, so there's no
fast way to verify this.
I'll be testing with your patch now, and I'll let you know if I hit
the bug again.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
