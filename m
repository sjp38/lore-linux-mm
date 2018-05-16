Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id E03DD6B036C
	for <linux-mm@kvack.org>; Wed, 16 May 2018 17:21:50 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id f23-v6so1565753wra.20
        for <linux-mm@kvack.org>; Wed, 16 May 2018 14:21:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 189-v6sor931779wmu.47.2018.05.16.14.21.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 16 May 2018 14:21:49 -0700 (PDT)
MIME-Version: 1.0
References: <20180516202023.167627-1-shakeelb@google.com> <90167afa-ecfb-c5ef-3554-ddb7e6ac9728@suse.cz>
In-Reply-To: <90167afa-ecfb-c5ef-3554-ddb7e6ac9728@suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 16 May 2018 14:21:35 -0700
Message-ID: <CALvZod6PebHBeqp_kJ47S_vMYKmHnAP5er4+03O=5XGFiyHfHA@mail.gmail.com>
Subject: Re: [PATCH] mm: save two stranding bit in gfp_mask
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Mel Gorman <mgorman@techsingularity.net>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, May 16, 2018 at 1:41 PM Vlastimil Babka <vbabka@suse.cz> wrote:
> On 05/16/2018 10:20 PM, Shakeel Butt wrote:
> > ___GFP_COLD and ___GFP_OTHER_NODE were removed but their bits were
> > stranded. Slide existing gfp masks to make those two bits available.
> Well, there are already available for hypothetical new flags. Is there
> anything that benefits from a smaller __GFP_BITS_SHIFT?

I am prototyping to pass along the type of kmem allocation e.g. page table,
vmalloc, stack e.t.c. (still very preliminary).
