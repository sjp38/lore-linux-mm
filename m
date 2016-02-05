Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f49.google.com (mail-lf0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 993F84403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 23:56:09 -0500 (EST)
Received: by mail-lf0-f49.google.com with SMTP id m1so50780062lfg.0
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 20:56:09 -0800 (PST)
Received: from mail-lf0-x233.google.com (mail-lf0-x233.google.com. [2a00:1450:4010:c07::233])
        by mx.google.com with ESMTPS id k2si8782779lbs.199.2016.02.04.20.56.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Feb 2016 20:56:08 -0800 (PST)
Received: by mail-lf0-x233.google.com with SMTP id 78so49936266lfy.3
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 20:56:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1454643648-10002-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1454643648-10002-1-git-send-email-matthew.r.wilcox@intel.com>
Date: Fri, 5 Feb 2016 07:56:07 +0300
Message-ID: <CALYGNiPopvgU0xqpykK2MfB3ejh_mq5M99FB4D47F11h3Entgg@mail.gmail.com>
Subject: Re: [PATCH 0/2] Radix tree retry bug fix & test case
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Feb 5, 2016 at 6:40 AM, Matthew Wilcox
<matthew.r.wilcox@intel.com> wrote:
> Konstantin pointed out my braino when using radix_tree_iter_retry(),
> and then pointed out a second braino.  I think we can fix both brainos
> with one simple test (the advantage of having your braino pointed out
> to you is that you know what you were expecting to happen, so you can
> sometimes propose simlpy making happen what you expected to happen.
> Konstantin doesn't have access to my though tprocesses.)
>
> Kontantin wrote a really great test ... and then didn't add it to the
> test suite.  That made me sad, so I added it.

I haven't seen them, I wasn't in CC. And I prefer testing in vivo if possible.

>
> Andrew, can you drop radix-tree-fix-oops-after-radix_tree_iter_retry.patch
> from your tree and add these two patches instead?  If you prefer
> Konstantin's fix to this one, I'll send you another patch to fix the
> second problem Konstantin pointed out.

Nak. Mine version generates better code. radix_tree_next_slot is a hot place.
Please fix second problem in your helper separately.

>
> I was a bit unsure about the proper attribution here.  The essentials
> of the test-suite change from Konstantin are unchanged, but he didn't
> have his own sign-off on it.  So I made him 'From' and only added my
> own sign-off.
>
> Konstantin Khlebnikov (1):
>   radix-tree tests: Add regression3 test
>
> Matthew Wilcox (1):
>   radix-tree: fix oops after radix_tree_iter_retry
>
>  include/linux/radix-tree.h              |  3 ++
>  tools/testing/radix-tree/Makefile       |  2 +-
>  tools/testing/radix-tree/linux/kernel.h |  1 +
>  tools/testing/radix-tree/main.c         |  1 +
>  tools/testing/radix-tree/regression.h   |  1 +
>  tools/testing/radix-tree/regression3.c  | 86 +++++++++++++++++++++++++++++++++
>  6 files changed, 93 insertions(+), 1 deletion(-)
>  create mode 100644 tools/testing/radix-tree/regression3.c
>
> --
> 2.7.0.rc3
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
