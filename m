Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B605C6B0069
	for <linux-mm@kvack.org>; Sat, 22 Oct 2016 14:51:06 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b80so11142391wme.5
        for <linux-mm@kvack.org>; Sat, 22 Oct 2016 11:51:06 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id q4si8207193wjo.250.2016.10.22.11.51.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 22 Oct 2016 11:51:05 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id d128so3594713wmf.0
        for <linux-mm@kvack.org>; Sat, 22 Oct 2016 11:51:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALZtONBYifCupwSWx7mcnrQDxF5FLV0KToDyz57u7ZgKrVqUrw@mail.gmail.com>
References: <20161019183340.9e3738b403ddda1a04c8f906@gmail.com>
 <20161019183557.5371f48b064079807c65c92a@gmail.com> <CALZtONBYifCupwSWx7mcnrQDxF5FLV0KToDyz57u7ZgKrVqUrw@mail.gmail.com>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Sat, 22 Oct 2016 20:51:04 +0200
Message-ID: <CAMJBoFNzsAf8463=H6Phg9vaPzXWVJ5qTQMMcB52O3ZQVVo=Ew@mail.gmail.com>
Subject: Re: [PATCH 2/3] z3fold: remove redundant locking
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Oct 20, 2016 at 10:15 PM, Dan Streetman <ddstreet@ieee.org> wrote:
> On Wed, Oct 19, 2016 at 12:35 PM, Vitaly Wool <vitalywool@gmail.com> wrote:
>> The per-pool z3fold spinlock should generally be taken only when
>> a non-atomic pool variable is modified. There's no need to take it
>> to map/unmap an object. This patch introduces per-page lock that
>> will be used instead to protect per-page variables in map/unmap
>> functions.
>
> I think the per-page lock must be held around almost all access to any
> page zhdr data; previously that was protected by the pool lock.

Right, except for list operations. At this point I think per-page
locks will have to be
thought over again, and there is some nice performance gain from making spinlock
a rwlock anyway, so I'll stick with the latest patchset, fixing tiny
bits like wrong
unbuddied_nr increment in the other patch.

Best regards,
   Vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
