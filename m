Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0469C6B025F
	for <linux-mm@kvack.org>; Sun, 13 Aug 2017 20:49:18 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u199so107520697pgb.13
        for <linux-mm@kvack.org>; Sun, 13 Aug 2017 17:49:17 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id m7si3453817pgd.713.2017.08.13.17.49.16
        for <linux-mm@kvack.org>;
        Sun, 13 Aug 2017 17:49:16 -0700 (PDT)
Date: Mon, 14 Aug 2017 09:49:10 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v6 4/7] mm: refactoring TLB gathering API
Message-ID: <20170814004910.GA25427@bbox>
References: <20170802000818.4760-1-namit@vmware.com>
 <20170802000818.4760-5-namit@vmware.com>
 <20170811092334.rmeazkklvordrmrl@hirez.programming.kicks-ass.net>
 <EBBFF419-4E4C-440A-853B-25FB6F0DE7F6@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <EBBFF419-4E4C-440A-853B-25FB6F0DE7F6@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Russell King <linux@armlinux.org.uk>, Tony Luck <tony.luck@intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, "David S. Miller" <davem@davemloft.net>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Jeff Dike <jdike@addtoit.com>, linux-arch@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>

On Fri, Aug 11, 2017 at 10:12:45AM -0700, Nadav Amit wrote:
> Peter Zijlstra <peterz@infradead.org> wrote:
> 
> > On Tue, Aug 01, 2017 at 05:08:15PM -0700, Nadav Amit wrote:
> >> From: Minchan Kim <minchan@kernel.org>
> >> 
> >> This patch is a preparatory patch for solving race problems caused by
> >> TLB batch.  For that, we will increase/decrease TLB flush pending count
> >> of mm_struct whenever tlb_[gather|finish]_mmu is called.
> >> 
> >> Before making it simple, this patch separates architecture specific
> >> part and rename it to arch_tlb_[gather|finish]_mmu and generic part
> >> just calls it.
> > 
> > I absolutely hate this. We should unify this stuff, not diverge it
> > further.
> 
> Agreed, but I dona??t see how this patch makes the situation any worse.

Agree with Nadav. I don't think this patch makes things diverge further.
Peter, If you are strong against of it, please tell us what part you
are hating.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
