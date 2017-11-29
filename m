Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A96D96B0033
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 04:27:22 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id q3so1804096pgv.16
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 01:27:22 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r18sor387789pgd.80.2017.11.29.01.27.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 Nov 2017 01:27:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 29 Nov 2017 10:27:00 +0100
Message-ID: <CACT4Y+ZwvVG7aEiZWj-OmbxVdQyFj0ebXnakjeVnar-GQACBfg@mail.gmail.com>
Subject: Re: [PATCH 00/18] introduce a new tool, valid access checker
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Namhyung Kim <namhyung@kernel.org>, Wengang Wang <wen.gang.wang@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andi Kleen <ak@linux.intel.com>

On Tue, Nov 28, 2017 at 8:48 AM,  <js1304@gmail.com> wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> Hello,
>
> This patchset introduces a new tool, valid access checker.
>
> Vchecker is a dynamic memory error detector. It provides a new debug feature
> that can find out an un-intended access to valid area. Valid area here means
> the memory which is allocated and allowed to be accessed by memory owner and
> un-intended access means the read/write that is initiated by non-owner.
> Usual problem of this class is memory overwritten.
>
> Most of debug feature focused on finding out un-intended access to
> in-valid area, for example, out-of-bound access and use-after-free, and,
> there are many good tools for it. But, as far as I know, there is no good tool
> to find out un-intended access to valid area. This kind of problem is really
> hard to solve so this tool would be very useful.
>
> This tool doesn't automatically catch a problem. Manual runtime configuration
> to specify the target object is required.
>
> Note that there was a similar attempt for the debugging overwritten problem
> however it requires manual code modifying and recompile.
>
> http://lkml.kernel.org/r/<20171117223043.7277-1-wen.gang.wang@oracle.com>
>
> To get more information about vchecker, please see a documention at
> the last patch.
>
> Patchset can also be available at
>
> https://github.com/JoonsooKim/linux/tree/vchecker-master-v1.0-next-20171122
>
> Enjoy it.


Hi Joonsoo,

I skimmed through the code and this looks fine from KASAN point of
view (minimal code changes and no perf impact).
I don't feel like I can judge if this should go in or not. I will not
use this, we use KASAN for large-scale testing, but vchecker is in a
different bucket, it is meant for developers debugging hard bugs.
Wengang come up with a very similar change, and Andi said that this
looks useful.

If the decision is that this goes in, please let me take a closer look
before this is merged.

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
