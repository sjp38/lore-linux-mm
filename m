Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id ECD886B01D1
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 09:16:11 -0400 (EDT)
Date: Mon, 21 Jun 2010 15:16:08 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [Lsf10-pc] Current MM topics for LSF10/MM Summit 8-9 August in
 Boston
Message-ID: <20100621131608.GW5787@random.random>
References: <1276721459.2847.399.camel@mulgrave.site>
 <20100621120526.GA31679@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100621120526.GA31679@laptop>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, lsf10-pc@lists.linuxfoundation.org, linux-scsi@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 21, 2010 at 10:05:26PM +1000, Nick Piggin wrote:
> Andrea Arcangeli	Transparent hugepages

Sure fine on my side. I got a proposal accepted for presentation at
KVM Forum 2010 about it too the days after the VM summit too.

> KOSAKI Motohiro		get_user_pages vs COW problem

Just a side note, not sure exactly what is meant to be discussed about
this bug, considering the fact this is still unsolved isn't technical
problem as there were plenty of fixes available, and the one that seem
to had better chance to get included was the worst one in my view, as
it tried to fix it in a couple of gup caller (but failed, also because
finding all put_page pin release is kind of a pain as they're spread
all over the place and not identified as gup_put_page, and in addition
to the instability and lack of completeness of the fix, it was also
the most inefficient as it added unnecessary and coarse locking) plus
all gup callers are affected, not just a few. I normally call it gup
vs fork race. Luckily not all threaded apps uses O_DIRECT and fork and
pretend to do the direct-io in different sub-page chunks of the same
page from different threads (KVM would probably be affected if it
didn't use MADV_DONTFORK on the O_DIRECT memory, as it might run fork
to execute some network script when adding an hotplug pci net device
for example). But surely we can discuss the fix we prefer for this
bug, or at least we can agree it needs fixing.

Other topics looks very interesting too!

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
