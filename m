Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3BE566B0513
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 06:31:02 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 185so1908242wmk.12
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 03:31:02 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id g54si15539924wrg.391.2017.08.01.03.31.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Aug 2017 03:31:00 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id D26779947D
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 10:30:59 +0000 (UTC)
Date: Tue, 1 Aug 2017 11:30:55 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH v2 1/4] mm: refactoring TLB gathering API
Message-ID: <20170801103032.h7tnxryoxx7k7aqg@techsingularity.net>
References: <1501566977-20293-1-git-send-email-minchan@kernel.org>
 <1501566977-20293-2-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1501566977-20293-2-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team <kernel-team@lge.com>, Ingo Molnar <mingo@redhat.com>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, "David S. Miller" <davem@davemloft.net>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Jeff Dike <jdike@addtoit.com>, linux-arch@vger.kernel.org, Nadav Amit <nadav.amit@gmail.com>

On Tue, Aug 01, 2017 at 02:56:14PM +0900, Minchan Kim wrote:
> This patch is ready for solving race problems caused by TLB batch.

s/is ready/is a preparatory patch/

> For that, we will increase/decrease TLB flush pending count of
> mm_struct whenever tlb_[gather|finish]_mmu is called.
> 
> Before making it simple, this patch separates architecture specific
> part and rename it to arch_tlb_[gather|finish]_mmu and generic part
> just calls it.
> 
> It shouldn't change any behavior.
> 
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Russell King <linux@armlinux.org.uk>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
> Cc: Jeff Dike <jdike@addtoit.com>
> Cc: linux-arch@vger.kernel.org
> Cc: Nadav Amit <nadav.amit@gmail.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

You could alias arch_generic_tlb_finish_mmu as arch_tlb_gather_mmu
simiilar to how other arch-generic helpers are done to avoid some
#ifdeffery but otherwise

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
