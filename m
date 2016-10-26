Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id EFD486B0275
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 14:18:53 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id e12so4625329oib.5
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 11:18:53 -0700 (PDT)
Received: from mail-oi0-x242.google.com (mail-oi0-x242.google.com. [2607:f8b0:4003:c06::242])
        by mx.google.com with ESMTPS id u52si2395967otb.39.2016.10.26.11.18.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 11:18:53 -0700 (PDT)
Received: by mail-oi0-x242.google.com with SMTP id n202so358388oig.2
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 11:18:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20161024184739.GB2125@cmpxchg.org>
References: <20161019172428.7649-1-hannes@cmpxchg.org> <CA+55aFzRZCt-t_HJ_40mkuvR4qXj71BoW-Tt6hYOKNpT2yj6cw@mail.gmail.com>
 <20161024184739.GB2125@cmpxchg.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 26 Oct 2016 11:18:52 -0700
Message-ID: <CA+55aFwZR=5XF4fU2PNp4Demyinxqd4JGSqfG14SyBaz9CW9aQ@mail.gmail.com>
Subject: Re: [PATCH 0/5] mm: workingset: radix tree subtleties & single-page
 file refaults
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Dave Jones <davej@codemonkey.org.uk>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, kernel-team <kernel-team@fb.com>

On Mon, Oct 24, 2016 at 11:47 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
>
> How about this instead: given that we already mark the shadow entries
> exceptional, and the exceptional bit is part of the radix tree API,
> can we just introduce a node->exceptional counter for those entries
> and have the radix tree code assist us with that instead? It adds the
> counting for non-shadow exceptional entries as well (shmem swap slots,
> and DAX non-page entries), unfortunately, but this is way cleaner. It
> also makes mapping->nrexceptional and node->exceptional consistent in
> DAX (Jan, could you please double check the accounting there?)
>
> What do you think? Lightly tested patch below.

This certainly looks way better to me. I didn't *test* it, but it
doesn't make me scratch my head the way your previous patch did.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
