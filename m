Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9FF34680FBC
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 13:43:28 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id t188so16360274oih.15
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 10:43:28 -0700 (PDT)
Received: from mail-oi0-x243.google.com (mail-oi0-x243.google.com. [2607:f8b0:4003:c06::243])
        by mx.google.com with ESMTPS id w10si10445894oib.31.2017.07.05.10.43.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 10:43:27 -0700 (PDT)
Received: by mail-oi0-x243.google.com with SMTP id f134so21369017oig.0
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 10:43:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170705165602.15005-1-mhocko@kernel.org>
References: <20170705165602.15005-1-mhocko@kernel.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 5 Jul 2017 10:43:27 -0700
Message-ID: <CA+55aFxxeCtZ-PBqrZK5K2nDjCFBWRMKE09Bz650ZiR2h=b8dg@mail.gmail.com>
Subject: Re: [PATCH] mm: mm, mmap: do not blow on PROT_NONE MAP_FIXED holes in
 the stack
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Ben Hutchings <ben@decadent.org.uk>, Willy Tarreau <w@1wt.eu>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.com>

On Wed, Jul 5, 2017 at 9:56 AM, Michal Hocko <mhocko@kernel.org> wrote:
>
> "mm: enlarge stack guard gap" has introduced a regression in some rust
> and Java environments which are trying to implement their own stack
> guard page.  They are punching a new MAP_FIXED mapping inside the
> existing stack Vma.

Hmm. What version is this patch against? It doesn't seem to match my 4.12 tree.

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
