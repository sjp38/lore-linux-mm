Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B53B66B02DB
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 17:24:09 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id u144so3860959wmu.1
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 14:24:09 -0700 (PDT)
Received: from mail-wm0-x235.google.com (mail-wm0-x235.google.com. [2a00:1450:400c:c09::235])
        by mx.google.com with ESMTPS id r1si1076728wmf.122.2016.11.03.14.24.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Nov 2016 14:24:08 -0700 (PDT)
Received: by mail-wm0-x235.google.com with SMTP id t79so13007565wmt.0
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 14:24:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20161103141404.2bb6b59435e560f0b82c0a18@linux-foundation.org>
References: <20161103220058.3017148c790b352c0ec521d4@gmail.com> <20161103141404.2bb6b59435e560f0b82c0a18@linux-foundation.org>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Thu, 3 Nov 2016 22:24:07 +0100
Message-ID: <CAMJBoFOJqSk+KE8y_jtvGe5TBHevei7ZRjg93tvb1MuqaO9BZg@mail.gmail.com>
Subject: Re: [PATCH] z3fold: make pages_nr atomic
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dan Streetman <ddstreet@ieee.org>

On Thu, Nov 3, 2016 at 10:14 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Thu, 3 Nov 2016 22:00:58 +0100 Vitaly Wool <vitalywool@gmail.com> wrote:
>
>> This patch converts pages_nr per-pool counter to atomic64_t.
>
> Which is slower.
>
> Presumably there is a reason for making this change.  This reason
> should be described in the changelog.

The reason [which I thought was somewhat obvious :) ] is that there
won't be a need to take a per-pool lock to read or modify that
counter.

Best regards,
   Vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
