Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1ADF790015D
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 00:15:44 -0400 (EDT)
Received: by iyl8 with SMTP id 8so485046iyl.14
        for <linux-mm@kvack.org>; Tue, 21 Jun 2011 21:15:42 -0700 (PDT)
From: Nai Xia <nai.xia@gmail.com>
Reply-To: nai.xia@gmail.com
Subject: Re: [PATCH 0/2 V2] ksm: take dirty bit as reference to avoid volatile pages scanning
Date: Wed, 22 Jun 2011 12:15:23 +0800
References: <201106212055.25400.nai.xia@gmail.com> <20110622004608.GS25383@sequoia.sous-sol.org>
In-Reply-To: <20110622004608.GS25383@sequoia.sous-sol.org>
MIME-Version: 1.0
Message-Id: <201106221215.23996.nai.xia@gmail.com>
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Undisclosed.Recipients:"@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <izik.eidus@ravellosystems.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Chris Wright <chrisw@sous-sol.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Wednesday 22 June 2011 08:46:08 you wrote:
> * Nai Xia (nai.xia@gmail.com) wrote:
> > Compared to the first version, this patch set addresses the problem of
> > dirty bit updating of virtual machines, by adding two mmu_notifier interfaces.
> > So it can now track the volatile working set inside KVM guest OS.
> > 
> > V1 log:
> > Currently, ksm uses page checksum to detect volatile pages. Izik Eidus 
> > suggested that we could use pte dirty bit to optimize. This patch series
> > adds this new logic.
> > 
> > Preliminary benchmarks show that the scan speed is improved by up to 16 
> > times on volatile transparent huge pages and up to 8 times on volatile 
> > regular pages.
> 
> Did you run this only in the host (which would not trigger the notifiers
> to kvm), or also run your test program in a guest?

Yeah, I did run the test program in guest but I mean the top speed is measured in
host. i.e. I do confirm the ksmd can skip the pages of this test in guest OS 
but did not measure the speed up on guest.

Thanks, 

Nai
> 
> thanks,
> -chris
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
