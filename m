Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id C337C6B0038
	for <linux-mm@kvack.org>; Tue, 10 Jan 2017 15:49:27 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id f2so134624573uaf.2
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 12:49:27 -0800 (PST)
Received: from mail-vk0-x241.google.com (mail-vk0-x241.google.com. [2607:f8b0:400c:c05::241])
        by mx.google.com with ESMTPS id 3si874495uaa.182.2017.01.10.12.49.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jan 2017 12:49:26 -0800 (PST)
Received: by mail-vk0-x241.google.com with SMTP id n19so187686vkd.3
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 12:49:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALZtONAOgKLfRQbXR+xxhRWW2QyQghoLA_ownxK7_RZ8D5wOYw@mail.gmail.com>
References: <20161226013016.968004f3db024ef2111dc458@gmail.com>
 <20161226013448.d02b73ea0fca7edf0537162b@gmail.com> <CALZtONAOgKLfRQbXR+xxhRWW2QyQghoLA_ownxK7_RZ8D5wOYw@mail.gmail.com>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Tue, 10 Jan 2017 21:49:26 +0100
Message-ID: <CAMJBoFMDp2gbJ+CcX4T8nYcTZ-s4E4jAGsE46qfqUB1J9N2NtQ@mail.gmail.com>
Subject: Re: [PATCH/RESEND 2/5] mm/z3fold.c: extend compaction function
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Jan 4, 2017 at 4:43 PM, Dan Streetman <ddstreet@ieee.org> wrote:

<snip>
>>  static int z3fold_compact_page(struct z3fold_header *zhdr)
>>  {
>>         struct page *page = virt_to_page(zhdr);
>> -       void *beg = zhdr;
>> +       int ret = 0;
>
> I still don't understand why you're adding ret and using goto.  Just
> use return for each failure case.

I guess it's a matter of taste, I prefer having single function exit
elsewhere so I do it here too.

>> +
>> +       if (test_bit(MIDDLE_CHUNK_MAPPED, &page->private))
>> +               goto out;
>>
>> +       if (zhdr->middle_chunks != 0) {
>
> you appear to have just re-sent all your patches without addressing
> comments; in patch 4 you invert the check and return, which is what
> you should have done here in the first place, as that change is
> unrelated to that patch.

Not quite, I just thought we'd agreed on the patch 4 being separate. I
folded the locking fixes but not header size fixes.

~vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
