Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id 3A7146B0038
	for <linux-mm@kvack.org>; Mon,  7 Sep 2015 12:40:02 -0400 (EDT)
Received: by lagj9 with SMTP id j9so55337264lag.2
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 09:40:01 -0700 (PDT)
Received: from mail-lb0-x22b.google.com (mail-lb0-x22b.google.com. [2a00:1450:4010:c04::22b])
        by mx.google.com with ESMTPS id x3si434926lax.158.2015.09.07.09.40.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Sep 2015 09:40:00 -0700 (PDT)
Received: by lbbmp1 with SMTP id mp1so41664603lbb.1
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 09:39:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAAeHK+zErydFj8Pqzxj_pM3vtSYAezFMDvRE4CkROjTV=TiPRA@mail.gmail.com>
References: <CAAeHK+zUJ74Zn17=rOyxacHU18SgCfC6bsYW=6kCY5GXJBwGfQ@mail.gmail.com>
	<20150902194019.GL22326@mtj.duckdns.org>
	<CAAeHK+yZ_696uNf3XFObjCxiG_J3BYvfG_YSMaPEmjuyZdfOzw@mail.gmail.com>
	<CAAeHK+zErydFj8Pqzxj_pM3vtSYAezFMDvRE4CkROjTV=TiPRA@mail.gmail.com>
Date: Mon, 7 Sep 2015 18:39:59 +0200
Message-ID: <CAAeHK+y=xsnyMy47_Hs1aXNRRpHMDY18Y8uzfAPWHkW3f0+i3Q@mail.gmail.com>
Subject: Fwd: Use-after-free in page_cache_async_readahead
From: Andrey Konovalov <andreyknvl@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Jens Axboe <axboe@fb.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, Kostya Serebryany <kcc@google.com>

On Thu, Sep 3, 2015 at 1:49 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> On Wed, Sep 2, 2015 at 9:40 PM, Tejun Heo <tj@kernel.org> wrote:
>> Hello, Andrey.
>
> Hello Tejun,
>
>> On Wed, Sep 02, 2015 at 01:08:52PM +0200, Andrey Konovalov wrote:
>>> While running KASAN on 4.2 with Trinity I got the following report:
>>>
>>> ==================================================================
>>> BUG: KASan: use after free in page_cache_async_readahead+0x2cb/0x3f0
>>> at addr ffff880034bf6690
>>> Read of size 8 by task sshd/2571
>>> =============================================================================
>>> BUG kmalloc-16 (Tainted: G        W      ): kasan: bad access detected
>>> -----------------------------------------------------------------------------
>>>
>>> Disabling lock debugging due to kernel taint
>>> INFO: Allocated in bdi_init+0x168/0x960 age=554826 cpu=0 pid=6
>>
>> Can you please verify that the following patch fixes the issue?
>
> I've hit this bug only twice during 24 hours of fuzzing, so there's no
> fast way to verify this.
> I'll be testing with your patch now, and I'll let you know if I hit
> the bug again.

Hello Tejun,

I haven't seen any reports while testing with your patch for the last
few days, so I think it's safe to say that your patch fixes the issue.

Thanks!

>
> Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
