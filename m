Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 60C4E6B0038
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 17:51:48 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 123so2541883wmb.4
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 14:51:48 -0700 (PDT)
Received: from mail-wm0-x22a.google.com (mail-wm0-x22a.google.com. [2a00:1450:400c:c09::22a])
        by mx.google.com with ESMTPS id z2si7006114wje.203.2016.10.11.14.51.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Oct 2016 14:51:47 -0700 (PDT)
Received: by mail-wm0-x22a.google.com with SMTP id c78so11580080wme.1
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 14:51:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20161011213648.GC27872@dastard>
References: <20161011231408.2728c93ad89acb517fc6c9f0@gmail.com> <20161011213648.GC27872@dastard>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Tue, 11 Oct 2016 23:51:46 +0200
Message-ID: <CAMJBoFPWVGfwPK5gC+MJOXHQ=d4D+MM+6yBNVXEiVmCnKW_44Q@mail.gmail.com>
Subject: Re: [PATCH] z3fold: add shrinker
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Oct 11, 2016 at 11:36 PM, Dave Chinner <david@fromorbit.com> wrote:
> On Tue, Oct 11, 2016 at 11:14:08PM +0200, Vitaly Wool wrote:
>> This patch implements shrinker for z3fold. This shrinker
>> implementation does not free up any pages directly but it allows
>> for a denser placement of compressed objects which results in
>> less actual pages consumed and higher compression ratio therefore.
>>
>> Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
>
> This seems to implement the shrinker API we removed a ~3 years ago
> (commit a0b02131c5fc ("shrinker: Kill old ->shrink API.")). Forward
> porting and testing required, perhaps?

Bah, right. That's the wrong patch I submitted (for the 3.10-stable).

Thanks for pointing out, I'll come up with the right patch shortly.

~vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
