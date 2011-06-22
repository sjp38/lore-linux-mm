Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B63036B01A8
	for <linux-mm@kvack.org>; Tue, 21 Jun 2011 20:46:19 -0400 (EDT)
Date: Tue, 21 Jun 2011 17:46:08 -0700
From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [PATCH 0/2 V2] ksm: take dirty bit as reference to avoid
 volatile pages scanning
Message-ID: <20110622004608.GS25383@sequoia.sous-sol.org>
References: <201106212055.25400.nai.xia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201106212055.25400.nai.xia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nai Xia <nai.xia@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <izik.eidus@ravellosystems.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Chris Wright <chrisw@sous-sol.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel <linux-kernel@vger.kernel.org>

* Nai Xia (nai.xia@gmail.com) wrote:
> Compared to the first version, this patch set addresses the problem of
> dirty bit updating of virtual machines, by adding two mmu_notifier interfaces.
> So it can now track the volatile working set inside KVM guest OS.
> 
> V1 log:
> Currently, ksm uses page checksum to detect volatile pages. Izik Eidus 
> suggested that we could use pte dirty bit to optimize. This patch series
> adds this new logic.
> 
> Preliminary benchmarks show that the scan speed is improved by up to 16 
> times on volatile transparent huge pages and up to 8 times on volatile 
> regular pages.

Did you run this only in the host (which would not trigger the notifiers
to kvm), or also run your test program in a guest?

thanks,
-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
