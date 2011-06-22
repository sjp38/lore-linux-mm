Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A2346900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 19:44:57 -0400 (EDT)
Date: Thu, 23 Jun 2011 01:44:50 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mmu_notifier, kvm: Introduce dirty bit tracking in spte
 and mmu notifier to help KSM dirty bit tracking
Message-ID: <20110622234450.GB20843@redhat.com>
References: <201106212055.25400.nai.xia@gmail.com>
 <201106212132.39311.nai.xia@gmail.com>
 <20110622150350.GX20843@redhat.com>
 <BANLkTim85ghrK9D4f19Pt5v1+HTMzVXxnw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTim85ghrK9D4f19Pt5v1+HTMzVXxnw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nai Xia <nai.xia@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <izik.eidus@ravellosystems.com>, Hugh Dickins <hughd@google.com>, Chris Wright <chrisw@sous-sol.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel <linux-kernel@vger.kernel.org>, kvm <kvm@vger.kernel.org>

On Thu, Jun 23, 2011 at 07:19:06AM +0800, Nai Xia wrote:
> OK, I'll have a try over other workarounds.
> I am not feeling good about need_pte_unmap myself. :-)

The usual way is to check VM_HUGETLB in the caller and to call another
function that doesn't kmap. Casting pmd_t to pte_t isn't really nice
(but hey we're also doing that exceptionally in smaps_pte_range for
THP, but it safe there because we're casting the value of the pmd, not
the pointer to the pmd, so the kmap is done by the pte version of the
caller and not done by the pmd version of the caller).

Is it done for migrate? Surely it's not for swapout ;).

> Thanks for viewing!

You're welcome!

JFYI I'll be offline on vacation for a week, starting tomorrow, so if
I don't answer in the next few days that's the reason but I'll follow
the progress in a week.

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
