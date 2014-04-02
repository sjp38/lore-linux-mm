Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 92C2A6B0083
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 03:07:56 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id r10so10746884pdi.30
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 00:07:56 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id e10si652849paw.87.2014.04.02.00.07.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 02 Apr 2014 00:07:54 -0700 (PDT)
Received: by mail-pa0-f43.google.com with SMTP id bj1so11094657pad.30
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 00:07:54 -0700 (PDT)
Date: Wed, 2 Apr 2014 14:06:01 +0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: [PATCH] x86,mm: delay TLB flush after clearing accessed bit
Message-ID: <20140402060601.GA31305@kernel.org>
References: <20140331113442.0d628362@annuminas.surriel.com>
 <CA+55aFzG=B3t_YaoCY_H1jmEgs+cYd--ZHz7XhGeforMRvNfEQ@mail.gmail.com>
 <533AE518.1090705@redhat.com>
 <CA+55aFx9KYTV_N3qjV6S9uu6iTiVZimXhZtUa9UYRkNR9P-7RQ@mail.gmail.com>
 <533B0603.7040301@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <533B0603.7040301@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>

On Tue, Apr 01, 2014 at 02:31:31PM -0400, Rik van Riel wrote:
> On 04/01/2014 12:21 PM, Linus Torvalds wrote:
> > On Tue, Apr 1, 2014 at 9:11 AM, Rik van Riel <riel@redhat.com> wrote:
> >>
> >> Memory pressure is not necessarily caused by the same process
> >> whose accessed bit we just cleared. Memory pressure may not
> >> even be caused by any process's virtual memory at all, but it
> >> could be caused by the page cache.
> > 
> > If we have that much memory pressure on the page cache without having
> > any memory pressure on the actual VM space, then the swap-out activity
> > will never be an issue anyway.
> > 
> > IOW, I think all these scenarios are made-up. I'd much rather go for
> > simpler implementation, and make things more complex only in the
> > presence of numbers. Of which we have none.
> 
> We've been bitten by the lack of a properly tracked accessed
> bit before, but admittedly that was with the KVM code and EPT.
> 
> I'll add my Acked-by: to Shaohua's original patch then, and
> will keep my eyes open for any problems that may or may not
> materialize...
> 
> Shaohua?

I'd agree to choose the simple implementation at current stage and check if
there are problems really.

Andrew,
can you please pick up my orginal patch "x86: clearing access bit don't
flush tlb" (with Rik's Ack)? Or I can resend it if you preferred.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
