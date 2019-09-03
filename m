Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DC22C3A5A5
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 23:42:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB3E721883
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 23:42:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=axtens.net header.i=@axtens.net header.b="AIRHruYm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB3E721883
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axtens.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3EA8E6B0003; Tue,  3 Sep 2019 19:42:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 39AA46B0006; Tue,  3 Sep 2019 19:42:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 28AE16B0007; Tue,  3 Sep 2019 19:42:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0068.hostedemail.com [216.40.44.68])
	by kanga.kvack.org (Postfix) with ESMTP id 081F26B0003
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 19:42:09 -0400 (EDT)
Received: from smtpin10.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 9FC23824CA24
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 23:42:08 +0000 (UTC)
X-FDA: 75895235136.10.table40_12a0739ed6a46
X-HE-Tag: table40_12a0739ed6a46
X-Filterd-Recvd-Size: 7506
Received: from mail-pf1-f194.google.com (mail-pf1-f194.google.com [209.85.210.194])
	by imf18.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 23:42:07 +0000 (UTC)
Received: by mail-pf1-f194.google.com with SMTP id d15so2416997pfo.10
        for <linux-mm@kvack.org>; Tue, 03 Sep 2019 16:42:07 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=axtens.net; s=google;
        h=from:to:cc:subject:in-reply-to:references:date:message-id
         :mime-version;
        bh=d3Uvki+kfJgt1m0UONqlkiavQ6oLL7OnGA9HqPCX/bA=;
        b=AIRHruYm217BkNNbELn4rzWRu2lVdGvFiEuUy9/LBzLsYWn7tEdN22R8Y7Ix3jRzU8
         vi11fisWq8csSt4oXJS1lipZtvV1zI0lONGn1udWn9lzDMaQDTMGUVK4vRHDPXY3cGe+
         f5BwJ5lmavFRl45vKN4vFDlQq5lLGETQewU3g=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:in-reply-to:references:date
         :message-id:mime-version;
        bh=d3Uvki+kfJgt1m0UONqlkiavQ6oLL7OnGA9HqPCX/bA=;
        b=hbzkxpkKj8ZHXduLnMCQ8LIIHop2BTFih+2M75hlkLydu5Bf/ccX9E6LwuyhDIK+O6
         6f0nmmdKzWwiAvppCFJaipHYtzDh1Ui2XWZnFDRJMlH1+IbImf0jwmu7b/5Jxd/TCrHC
         nYFrbWmG3EuhIbavQANs+ZvXDqwEkv4llT8dGFHcKkjYWnLdD/7KZTxdJwTAW+LmXOG3
         1SoNNQpS6Ucji4ffPXhaQ2u460ClUsgqHG35J90xWq/J9TtzXgoUr99fvb4XA6phN2rv
         zJhHmOI0Xdg87MNtKdIo/WfVW1qjp7PtrhG7EUYQklrLG3UNCtgD/TIqeJbclvshUbxL
         fOGA==
X-Gm-Message-State: APjAAAWxvIOvZ5Kg6JUKu0luzjd10G41F+yZEMwZ74pr57mEj+8+Jdf6
	8PzubUXaHFV6ki8FpyXD++nOLw==
X-Google-Smtp-Source: APXvYqxeNo3PMrJsRo3FgG7XCb00MrhJflwc1xD555RVHRItPittdp6EdRFQwCHwDzhPeLggQRWf8A==
X-Received: by 2002:a17:90a:cb89:: with SMTP id a9mr1908300pju.93.1567554126677;
        Tue, 03 Sep 2019 16:42:06 -0700 (PDT)
Received: from localhost (ppp167-251-205.static.internode.on.net. [59.167.251.205])
        by smtp.gmail.com with ESMTPSA id m24sm6976787pfa.37.2019.09.03.16.42.02
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 03 Sep 2019 16:42:05 -0700 (PDT)
From: Daniel Axtens <dja@axtens.net>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Mark Rutland <mark.rutland@arm.com>, Dmitry Vyukov <dvyukov@google.com>, Christophe Leroy <christophe.leroy@c-s.fr>, PowerPC <linuxppc-dev@lists.ozlabs.org>, gor@linux.ibm.com
Subject: Re: [PATCH v7 5/5] kasan debug: track pages allocated for vmalloc shadow
In-Reply-To: <CAAeHK+w_HKVh___E0j3hctt_efSPR3PwKuO5XNpf=w5obfYSSA@mail.gmail.com>
References: <20190903145536.3390-1-dja@axtens.net> <20190903145536.3390-6-dja@axtens.net> <CAAeHK+w_HKVh___E0j3hctt_efSPR3PwKuO5XNpf=w5obfYSSA@mail.gmail.com>
Date: Wed, 04 Sep 2019 09:41:51 +1000
Message-ID: <87ef0xt0ao.fsf@dja-thinkpad.axtens.net>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Andrey Konovalov <andreyknvl@google.com> writes:

> On Tue, Sep 3, 2019 at 4:56 PM Daniel Axtens <dja@axtens.net> wrote:
>>
>> Provide the current number of vmalloc shadow pages in
>> /sys/kernel/debug/kasan_vmalloc/shadow_pages.
>
> Maybe it makes sense to put this into /sys/kernel/debug/kasan/
> (without _vmalloc) and name e.g. vmalloc_shadow_pages? In case we want
> to expose more generic KASAN debugging info later.

We certainly could. I just wonder if this patch is useful on an ongoing
basis. I wrote it to validate my work on lazy freeing of shadow pages -
which is why I included it - but I'm not sure it has much ongoing value
beyond demonstrating that the freeing code works.

If we think it's worth holding on to this patch, I can certainly adjust
the paths.

Regards,
Daniel

>
>>
>> Signed-off-by: Daniel Axtens <dja@axtens.net>
>>
>> ---
>>
>> Merging this is probably overkill, but I leave it to the discretion
>> of the broader community.
>>
>> On v4 (no dynamic freeing), I saw the following approximate figures
>> on my test VM:
>>
>>  - fresh boot: 720
>>  - after test_vmalloc: ~14000
>>
>> With v5 (lazy dynamic freeing):
>>
>>  - boot: ~490-500
>>  - running modprobe test_vmalloc pushes the figures up to sometimes
>>     as high as ~14000, but they drop down to ~560 after the test ends.
>>     I'm not sure where the extra sixty pages are from, but running the
>>     test repeately doesn't cause the number to keep growing, so I don't
>>     think we're leaking.
>>  - with vmap_stack, spawning tasks pushes the figure up to ~4200, then
>>     some clearing kicks in and drops it down to previous levels again.
>> ---
>>  mm/kasan/common.c | 26 ++++++++++++++++++++++++++
>>  1 file changed, 26 insertions(+)
>>
>> diff --git a/mm/kasan/common.c b/mm/kasan/common.c
>> index e33cbab83309..e40854512417 100644
>> --- a/mm/kasan/common.c
>> +++ b/mm/kasan/common.c
>> @@ -35,6 +35,7 @@
>>  #include <linux/vmalloc.h>
>>  #include <linux/bug.h>
>>  #include <linux/uaccess.h>
>> +#include <linux/debugfs.h>
>>
>>  #include <asm/tlbflush.h>
>>
>> @@ -750,6 +751,8 @@ core_initcall(kasan_memhotplug_init);
>>  #endif
>>
>>  #ifdef CONFIG_KASAN_VMALLOC
>> +static u64 vmalloc_shadow_pages;
>> +
>>  static int kasan_populate_vmalloc_pte(pte_t *ptep, unsigned long addr,
>>                                       void *unused)
>>  {
>> @@ -776,6 +779,7 @@ static int kasan_populate_vmalloc_pte(pte_t *ptep, unsigned long addr,
>>         if (likely(pte_none(*ptep))) {
>>                 set_pte_at(&init_mm, addr, ptep, pte);
>>                 page = 0;
>> +               vmalloc_shadow_pages++;
>>         }
>>         spin_unlock(&init_mm.page_table_lock);
>>         if (page)
>> @@ -829,6 +833,7 @@ static int kasan_depopulate_vmalloc_pte(pte_t *ptep, unsigned long addr,
>>         if (likely(!pte_none(*ptep))) {
>>                 pte_clear(&init_mm, addr, ptep);
>>                 free_page(page);
>> +               vmalloc_shadow_pages--;
>>         }
>>         spin_unlock(&init_mm.page_table_lock);
>>
>> @@ -947,4 +952,25 @@ void kasan_release_vmalloc(unsigned long start, unsigned long end,
>>                                        (unsigned long)shadow_end);
>>         }
>>  }
>> +
>> +static __init int kasan_init_vmalloc_debugfs(void)
>> +{
>> +       struct dentry *root, *count;
>> +
>> +       root = debugfs_create_dir("kasan_vmalloc", NULL);
>> +       if (IS_ERR(root)) {
>> +               if (PTR_ERR(root) == -ENODEV)
>> +                       return 0;
>> +               return PTR_ERR(root);
>> +       }
>> +
>> +       count = debugfs_create_u64("shadow_pages", 0444, root,
>> +                                  &vmalloc_shadow_pages);
>> +
>> +       if (IS_ERR(count))
>> +               return PTR_ERR(root);
>> +
>> +       return 0;
>> +}
>> +late_initcall(kasan_init_vmalloc_debugfs);
>>  #endif
>> --
>> 2.20.1
>>
>> --
>> You received this message because you are subscribed to the Google Groups "kasan-dev" group.
>> To unsubscribe from this group and stop receiving emails from it, send an email to kasan-dev+unsubscribe@googlegroups.com.
>> To view this discussion on the web visit https://groups.google.com/d/msgid/kasan-dev/20190903145536.3390-6-dja%40axtens.net.

