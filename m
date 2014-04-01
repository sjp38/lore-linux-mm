Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f179.google.com (mail-vc0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id A6C146B0031
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 12:21:41 -0400 (EDT)
Received: by mail-vc0-f179.google.com with SMTP id ij19so9864620vcb.24
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 09:21:41 -0700 (PDT)
Received: from mail-vc0-x230.google.com (mail-vc0-x230.google.com [2607:f8b0:400c:c03::230])
        by mx.google.com with ESMTPS id vd8si3745018vdc.34.2014.04.01.09.21.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 01 Apr 2014 09:21:40 -0700 (PDT)
Received: by mail-vc0-f176.google.com with SMTP id lc6so9795533vcb.7
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 09:21:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <533AE518.1090705@redhat.com>
References: <20140331113442.0d628362@annuminas.surriel.com>
	<CA+55aFzG=B3t_YaoCY_H1jmEgs+cYd--ZHz7XhGeforMRvNfEQ@mail.gmail.com>
	<533AE518.1090705@redhat.com>
Date: Tue, 1 Apr 2014 09:21:40 -0700
Message-ID: <CA+55aFx9KYTV_N3qjV6S9uu6iTiVZimXhZtUa9UYRkNR9P-7RQ@mail.gmail.com>
Subject: Re: [PATCH] x86,mm: delay TLB flush after clearing accessed bit
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, shli@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>

On Tue, Apr 1, 2014 at 9:11 AM, Rik van Riel <riel@redhat.com> wrote:
>
> Memory pressure is not necessarily caused by the same process
> whose accessed bit we just cleared. Memory pressure may not
> even be caused by any process's virtual memory at all, but it
> could be caused by the page cache.

If we have that much memory pressure on the page cache without having
any memory pressure on the actual VM space, then the swap-out activity
will never be an issue anyway.

IOW, I think all these scenarios are made-up. I'd much rather go for
simpler implementation, and make things more complex only in the
presence of numbers. Of which we have none.

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
