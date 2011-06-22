Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6EBB6900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 11:46:50 -0400 (EDT)
Date: Wed, 22 Jun 2011 08:46:30 -0700
From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [PATCH] mmu_notifier, kvm: Introduce dirty bit tracking in spte
 and mmu notifier to help KSM dirty bit tracking
Message-ID: <20110622154630.GT25383@sequoia.sous-sol.org>
References: <201106212055.25400.nai.xia@gmail.com>
 <201106212132.39311.nai.xia@gmail.com>
 <20110622002123.GP25383@sequoia.sous-sol.org>
 <4E018897.7040707@ravellosystems.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4E018897.7040707@ravellosystems.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Izik Eidus <izik.eidus@ravellosystems.com>
Cc: Chris Wright <chrisw@sous-sol.org>, Nai Xia <nai.xia@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel <linux-kernel@vger.kernel.org>, kvm <kvm@vger.kernel.org>, mtosatti@redhat.com

* Izik Eidus (izik.eidus@ravellosystems.com) wrote:
> On 6/22/2011 3:21 AM, Chris Wright wrote:
> >* Nai Xia (nai.xia@gmail.com) wrote:
> >>+	if (!shadow_dirty_mask) {
> >>+		WARN(1, "KVM: do NOT try to test dirty bit in EPT\n");
> >>+		goto out;
> >>+	}
> >This should never fire with the dirty_update() notifier test, right?
> >And that means that this whole optimization is for the shadow mmu case,
> >arguably the legacy case.
> 
> Hi Chris,
> AMD npt does track the dirty bit in the nested page tables,
> so the shadow_dirty_mask should not be 0 in that case...

Yeah, momentary lapse... ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
