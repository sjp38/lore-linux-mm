Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C95B26B0583
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 20:56:57 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id r62so30623879pfj.1
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 17:56:57 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id k194si3741422pgc.764.2017.08.01.17.56.55
        for <linux-mm@kvack.org>;
        Tue, 01 Aug 2017 17:56:56 -0700 (PDT)
Date: Wed, 2 Aug 2017 09:56:54 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2 1/4] mm: refactoring TLB gathering API
Message-ID: <20170802005654.GB6388@bbox>
References: <1501566977-20293-1-git-send-email-minchan@kernel.org>
 <1501566977-20293-2-git-send-email-minchan@kernel.org>
 <20170801103032.h7tnxryoxx7k7aqg@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170801103032.h7tnxryoxx7k7aqg@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team <kernel-team@lge.com>, Ingo Molnar <mingo@redhat.com>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, "David S. Miller" <davem@davemloft.net>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Jeff Dike <jdike@addtoit.com>, linux-arch@vger.kernel.org, Nadav Amit <nadav.amit@gmail.com>

Hi Mel,

On Tue, Aug 01, 2017 at 11:30:55AM +0100, Mel Gorman wrote:
> On Tue, Aug 01, 2017 at 02:56:14PM +0900, Minchan Kim wrote:
> > This patch is ready for solving race problems caused by TLB batch.
> 
> s/is ready/is a preparatory patch/
> 
> > For that, we will increase/decrease TLB flush pending count of
> > mm_struct whenever tlb_[gather|finish]_mmu is called.
> > 
> > Before making it simple, this patch separates architecture specific
> > part and rename it to arch_tlb_[gather|finish]_mmu and generic part
> > just calls it.
> > 
> > It shouldn't change any behavior.
> > 
> > Cc: Ingo Molnar <mingo@redhat.com>
> > Cc: Russell King <linux@armlinux.org.uk>
> > Cc: Tony Luck <tony.luck@intel.com>
> > Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> > Cc: "David S. Miller" <davem@davemloft.net>
> > Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> > Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
> > Cc: Jeff Dike <jdike@addtoit.com>
> > Cc: linux-arch@vger.kernel.org
> > Cc: Nadav Amit <nadav.amit@gmail.com>
> > Cc: Mel Gorman <mgorman@techsingularity.net>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> 
> You could alias arch_generic_tlb_finish_mmu as arch_tlb_gather_mmu
> simiilar to how other arch-generic helpers are done to avoid some
> #ifdeffery but otherwise

Good idea. With Andrew's suggestion, Nadav will resend whole series
including his patchset. I asked to him to fix it when he respin.

> 
> Acked-by: Mel Gorman <mgorman@techsingularity.net>

Thanks for the review!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
