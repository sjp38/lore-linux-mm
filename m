Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 49063900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 11:19:40 -0400 (EDT)
Received: by wwf25 with SMTP id 25so923332wwf.3
        for <linux-mm@kvack.org>; Wed, 22 Jun 2011 08:19:37 -0700 (PDT)
Message-ID: <4E0207FE.9080002@ravellosystems.com>
Date: Wed, 22 Jun 2011 18:19:26 +0300
From: Izik Eidus <izik.eidus@ravellosystems.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mmu_notifier, kvm: Introduce dirty bit tracking in spte
 and mmu notifier to help KSM dirty bit tracking
References: <201106212055.25400.nai.xia@gmail.com> <201106212132.39311.nai.xia@gmail.com> <20110622150350.GX20843@redhat.com>
In-Reply-To: <20110622150350.GX20843@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Nai Xia <nai.xia@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Chris Wright <chrisw@sous-sol.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel <linux-kernel@vger.kernel.org>, kvm <kvm@vger.kernel.org>


> If we don't flush the smp tlb don't we risk that we'll insert pages in
> the unstable tree that are volatile just because the dirty bit didn't
> get set again on the spte?

Yes, this is the trade off we take, the unstable tree will be flushed 
anyway -
so this is nothing that won`t be recovered very soon after it happen...

and most of the chances the tlb will be flushed before ksm get there anyway
(specially for heavily modified page, that we don`t want in the unstable 
tree)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
