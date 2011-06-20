Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id AD68D6B0140
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 15:37:07 -0400 (EDT)
Date: Mon, 20 Jun 2011 21:37:02 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 3/3] mm: print information when THP is disabled
 automatically
Message-ID: <20110620193702.GH20843@redhat.com>
References: <1308587683-2555-1-git-send-email-amwang@redhat.com>
 <1308587683-2555-3-git-send-email-amwang@redhat.com>
 <20110620170106.GC9396@suse.de>
 <4DFF82E2.1010409@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4DFF82E2.1010409@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <amwang@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

Hi Cong,

On Tue, Jun 21, 2011 at 01:26:58AM +0800, Cong Wang wrote:
> But, there are many printk messages in the same file start with "hugepage:".
> :-) I can send a patch to replace all of them with "THP" if you want...

Those are in failure paths practically impossible to trigger unless
the memory layout is misconfigured and the kernel won't succeed
booting so I guess I didn't care much what I wrote in those 3 sorry.
Replacing those with THP surely sounds valid cleanup to avoid
confusion if you add a "THP:" prefix elsewhere.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
