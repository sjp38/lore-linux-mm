Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4FC5D6B042E
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 17:12:29 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id w185so5374817ita.5
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 14:12:29 -0800 (PST)
Received: from mail-it0-x232.google.com (mail-it0-x232.google.com. [2607:f8b0:4001:c0b::232])
        by mx.google.com with ESMTPS id b101si5317425ioj.150.2017.02.15.14.12.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Feb 2017 14:12:28 -0800 (PST)
Received: by mail-it0-x232.google.com with SMTP id c7so4436328itd.1
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 14:12:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170215130020.749e34e4d1e3d0789eb114f1@linux-foundation.org>
References: <20170209131625.GA16954@pjb1027-Latitude-E5410>
 <CAGXu5jKofDhycUbLGMLNPM3LwjKuW1kGAbthSS1qufEB6bwOPA@mail.gmail.com> <20170215130020.749e34e4d1e3d0789eb114f1@linux-foundation.org>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 15 Feb 2017 14:12:27 -0800
Message-ID: <CAGXu5jJ+KFOic1_JfD2iWfKdivKjteVqdybB7Jq=Eadcs72dwQ@mail.gmail.com>
Subject: Re: [PATCH] mm: testcases for RODATA: fix config dependency
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jinbum Park <jinb.park7@gmail.com>, Valentin Rothberg <valentinrothberg@gmail.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Laura Abbott <labbott@redhat.com>

On Wed, Feb 15, 2017 at 1:00 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Fri, 10 Feb 2017 15:36:37 -0800 Kees Cook <keescook@chromium.org> wrote:
>
>> >  config DEBUG_RODATA_TEST
>> >      bool "Testcase for the marking rodata read-only"
>> > -    depends on DEBUG_RODATA
>> > +    depends on STRICT_KERNEL_RWX
>> >      ---help---
>> >        This option enables a testcase for the setting rodata read-only.
>>
>> Great, thanks!
>>
>> Acked-by: Kees Cook <keescook@chromium.org>
>>
>> Andrew, do you want to take this patch, since it applies on top of
>> "mm: add arch-independent testcases for RODATA", or do you want me to
>> take both patches into my KSPP tree which has the DEBUG_RODATA ->
>> STRICT_KERNEL_RWX renaming series?
>
> I staged this and mm-add-arch-independent-testcases-for-rodata.patch
> after linux-next and shall merge them after the STRICT_KERNEL_RWX
> rename has gone into mainline.

Awesome, thanks!

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
