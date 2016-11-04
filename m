Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id DE2A16B02F7
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 03:27:44 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l124so10678081wml.4
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 00:27:44 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id k63si3565662wmb.43.2016.11.04.00.27.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Nov 2016 00:27:43 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id u144so2517591wmu.0
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 00:27:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20161103151700.73a98155238acff3f3f98e8b@linux-foundation.org>
References: <20161103220058.3017148c790b352c0ec521d4@gmail.com>
 <20161103141404.2bb6b59435e560f0b82c0a18@linux-foundation.org>
 <CAMJBoFOJqSk+KE8y_jtvGe5TBHevei7ZRjg93tvb1MuqaO9BZg@mail.gmail.com> <20161103151700.73a98155238acff3f3f98e8b@linux-foundation.org>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Fri, 4 Nov 2016 08:27:42 +0100
Message-ID: <CAMJBoFMK_WH7q_y_=JgCJJ70YSSUhza1nQ0qVdurO6ZUT_kRLw@mail.gmail.com>
Subject: Re: [PATCH] z3fold: make pages_nr atomic
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dan Streetman <ddstreet@ieee.org>

On Thu, Nov 3, 2016 at 11:17 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Thu, 3 Nov 2016 22:24:07 +0100 Vitaly Wool <vitalywool@gmail.com> wrote:
>
>> On Thu, Nov 3, 2016 at 10:14 PM, Andrew Morton
>> <akpm@linux-foundation.org> wrote:
>> > On Thu, 3 Nov 2016 22:00:58 +0100 Vitaly Wool <vitalywool@gmail.com> wrote:
>> >
>> >> This patch converts pages_nr per-pool counter to atomic64_t.
>> >
>> > Which is slower.
>> >
>> > Presumably there is a reason for making this change.  This reason
>> > should be described in the changelog.
>>
>> The reason [which I thought was somewhat obvious :) ] is that there
>> won't be a need to take a per-pool lock to read or modify that
>> counter.
>
> But the patch didn't change the locking.  And as far as I can tell,
> neither does "z3fold: extend compaction function".

Right. I'll come up with the locking rework shortly, but it will be a
RFC so I wanted to send it separately.

~vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
