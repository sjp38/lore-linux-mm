Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 81A9E6B0069
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 05:12:02 -0500 (EST)
Date: Mon, 21 Nov 2011 05:11:55 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [V2 PATCH] tmpfs: add fallocate support
Message-ID: <20111121101155.GC17887@infradead.org>
References: <1321612791-4764-1-git-send-email-amwang@redhat.com>
 <alpine.LSU.2.00.1111201300340.1264@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1111201300340.1264@sister.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Cong Wang <amwang@redhat.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Pekka Enberg <penberg@kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Lennart Poettering <lennart@poettering.net>, Kay Sievers <kay.sievers@vrfy.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org

On Sun, Nov 20, 2011 at 01:22:10PM -0800, Hugh Dickins wrote:
> First question that springs to mind (to which I shall easily find
> an answer): is it actually acceptable for fallocate() to return
> -ENOSPC when it has already completed a part of the work?

No, it must undo all allocations if it returns ENOSPC.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
