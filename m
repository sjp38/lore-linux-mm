Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 2EE976B003D
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 16:21:04 -0500 (EST)
Date: Thu, 5 Feb 2009 22:20:58 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [Patch] mmu_notifiers destroyed by __mmu_notifier_release()
	retain extra mm_count.
Message-ID: <20090205212058.GK14011@random.random>
References: <20090205172303.GB8559@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090205172303.GB8559@sgi.com>
Sender: owner-linux-mm@kvack.org
To: Robin Holt <holt@sgi.com>
Cc: linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 05, 2009 at 11:23:03AM -0600, Robin Holt wrote:
> 
> An application relying upon mmu_notifier_release for teardown of the
> mmu_notifiers will leak mm_structs.  At the do_mmu_notifier_register
> increments mm_count, but __mmu_notifier_release() does not decrement it.

Sure agreed, thanks! This got unnoticed this long because KVM uses the
unregister method instead of the self-disarming ->release and I guess
your systems have quite some ram so it'd take a while for the memleak
to trigger.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
