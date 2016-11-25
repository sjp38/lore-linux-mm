Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id ABBAF6B0069
	for <linux-mm@kvack.org>; Fri, 25 Nov 2016 09:34:29 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id 98so26827378lfs.0
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 06:34:29 -0800 (PST)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id q19si20536640lff.406.2016.11.25.06.34.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Nov 2016 06:34:28 -0800 (PST)
Received: by mail-lf0-x243.google.com with SMTP id 98so3453261lfs.0
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 06:34:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAMJBoFMK_WH7q_y_=JgCJJ70YSSUhza1nQ0qVdurO6ZUT_kRLw@mail.gmail.com>
References: <20161103220058.3017148c790b352c0ec521d4@gmail.com>
 <20161103141404.2bb6b59435e560f0b82c0a18@linux-foundation.org>
 <CAMJBoFOJqSk+KE8y_jtvGe5TBHevei7ZRjg93tvb1MuqaO9BZg@mail.gmail.com>
 <20161103151700.73a98155238acff3f3f98e8b@linux-foundation.org> <CAMJBoFMK_WH7q_y_=JgCJJ70YSSUhza1nQ0qVdurO6ZUT_kRLw@mail.gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Fri, 25 Nov 2016 09:33:47 -0500
Message-ID: <CALZtONDBviZ7HWyeERqG8-=5FLJCx8uMKKTj+5OHmKZ3-QX55w@mail.gmail.com>
Subject: Re: [PATCH] z3fold: make pages_nr atomic
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Nov 4, 2016 at 3:27 AM, Vitaly Wool <vitalywool@gmail.com> wrote:
> On Thu, Nov 3, 2016 at 11:17 PM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
>> On Thu, 3 Nov 2016 22:24:07 +0100 Vitaly Wool <vitalywool@gmail.com> wrote:
>>
>>> On Thu, Nov 3, 2016 at 10:14 PM, Andrew Morton
>>> <akpm@linux-foundation.org> wrote:
>>> > On Thu, 3 Nov 2016 22:00:58 +0100 Vitaly Wool <vitalywool@gmail.com> wrote:
>>> >
>>> >> This patch converts pages_nr per-pool counter to atomic64_t.
>>> >
>>> > Which is slower.
>>> >
>>> > Presumably there is a reason for making this change.  This reason
>>> > should be described in the changelog.
>>>
>>> The reason [which I thought was somewhat obvious :) ] is that there
>>> won't be a need to take a per-pool lock to read or modify that
>>> counter.
>>
>> But the patch didn't change the locking.  And as far as I can tell,
>> neither does "z3fold: extend compaction function".
>
> Right. I'll come up with the locking rework shortly, but it will be a
> RFC so I wanted to send it separately.

this is still in mmotm, and it seems the later patches rely on it, so
while i agree that the changelog should be clearer about why it's
needed, the change itself looks ok.

Acked-by: Dan Streetman <ddstreet@ieee.org>

>
> ~vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
