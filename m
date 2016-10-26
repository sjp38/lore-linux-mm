Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1BE486B0275
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 14:29:49 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b80so17234294wme.5
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 11:29:49 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id f196si12041463wme.70.2016.10.26.11.29.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 11:29:47 -0700 (PDT)
Date: Wed, 26 Oct 2016 14:29:42 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 0/5] mm: workingset: radix tree subtleties & single-page
 file refaults
Message-ID: <20161026182942.GA18258@cmpxchg.org>
References: <20161019172428.7649-1-hannes@cmpxchg.org>
 <CA+55aFzRZCt-t_HJ_40mkuvR4qXj71BoW-Tt6hYOKNpT2yj6cw@mail.gmail.com>
 <20161024184739.GB2125@cmpxchg.org>
 <CA+55aFwZR=5XF4fU2PNp4Demyinxqd4JGSqfG14SyBaz9CW9aQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwZR=5XF4fU2PNp4Demyinxqd4JGSqfG14SyBaz9CW9aQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Dave Jones <davej@codemonkey.org.uk>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, kernel-team <kernel-team@fb.com>

On Wed, Oct 26, 2016 at 11:18:52AM -0700, Linus Torvalds wrote:
> On Mon, Oct 24, 2016 at 11:47 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> >
> > How about this instead: given that we already mark the shadow entries
> > exceptional, and the exceptional bit is part of the radix tree API,
> > can we just introduce a node->exceptional counter for those entries
> > and have the radix tree code assist us with that instead? It adds the
> > counting for non-shadow exceptional entries as well (shmem swap slots,
> > and DAX non-page entries), unfortunately, but this is way cleaner. It
> > also makes mapping->nrexceptional and node->exceptional consistent in
> > DAX (Jan, could you please double check the accounting there?)
> >
> > What do you think? Lightly tested patch below.
> 
> This certainly looks way better to me. I didn't *test* it, but it
> doesn't make me scratch my head the way your previous patch did.

Awesome, thanks. I'll continue to beat on this for a while and then
send it on to Andrew.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
