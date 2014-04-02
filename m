Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id 920D66B0089
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 03:46:55 -0400 (EDT)
Received: by mail-we0-f170.google.com with SMTP id w61so7487954wes.15
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 00:46:54 -0700 (PDT)
Received: from mail-wi0-x22d.google.com (mail-wi0-x22d.google.com [2a00:1450:400c:c05::22d])
        by mx.google.com with ESMTPS id l8si11280845wif.10.2014.04.02.00.46.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 02 Apr 2014 00:46:54 -0700 (PDT)
Received: by mail-wi0-f173.google.com with SMTP id z2so4787381wiv.0
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 00:46:54 -0700 (PDT)
Date: Wed, 2 Apr 2014 09:46:51 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] x86,mm: delay TLB flush after clearing accessed bit
Message-ID: <20140402074651.GA22772@gmail.com>
References: <20140331113442.0d628362@annuminas.surriel.com>
 <CA+55aFzG=B3t_YaoCY_H1jmEgs+cYd--ZHz7XhGeforMRvNfEQ@mail.gmail.com>
 <533AE518.1090705@redhat.com>
 <CA+55aFx9KYTV_N3qjV6S9uu6iTiVZimXhZtUa9UYRkNR9P-7RQ@mail.gmail.com>
 <533B0603.7040301@redhat.com>
 <20140402060601.GA31305@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140402060601.GA31305@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>


* Shaohua Li <shli@kernel.org> wrote:

> On Tue, Apr 01, 2014 at 02:31:31PM -0400, Rik van Riel wrote:
> > On 04/01/2014 12:21 PM, Linus Torvalds wrote:
> > > On Tue, Apr 1, 2014 at 9:11 AM, Rik van Riel <riel@redhat.com> wrote:
> > >>
> > >> Memory pressure is not necessarily caused by the same process
> > >> whose accessed bit we just cleared. Memory pressure may not
> > >> even be caused by any process's virtual memory at all, but it
> > >> could be caused by the page cache.
> > > 
> > > If we have that much memory pressure on the page cache without having
> > > any memory pressure on the actual VM space, then the swap-out activity
> > > will never be an issue anyway.
> > > 
> > > IOW, I think all these scenarios are made-up. I'd much rather go for
> > > simpler implementation, and make things more complex only in the
> > > presence of numbers. Of which we have none.
> > 
> > We've been bitten by the lack of a properly tracked accessed
> > bit before, but admittedly that was with the KVM code and EPT.
> > 
> > I'll add my Acked-by: to Shaohua's original patch then, and
> > will keep my eyes open for any problems that may or may not
> > materialize...
> > 
> > Shaohua?
> 
> I'd agree to choose the simple implementation at current stage and check if
> there are problems really.
> 
> Andrew,
> can you please pick up my orginal patch "x86: clearing access bit don't
> flush tlb" (with Rik's Ack)? Or I can resend it if you preferred.

Please resend it so I can pick it up for this cycle, that approach 
obviously looks good.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
