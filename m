Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id AC1366B00DE
	for <linux-mm@kvack.org>; Mon,  2 Mar 2009 06:58:22 -0500 (EST)
Date: Mon, 2 Mar 2009 11:56:35 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH for mmotm] remove pagevec_swap_free()
In-Reply-To: <20090301190227.6FDB.A69D9226@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0903021153070.30226@blonde.anvils>
References: <20090225192550.GA5645@cmpxchg.org> <Pine.LNX.4.64.0902252022460.19132@blonde.anvils>
 <20090301190227.6FDB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 1 Mar 2009, KOSAKI Motohiro wrote:
> Subject: [PATCH] remove pagevec_swap_free()
> 
> pagevec_swap_free() is unused. 
> then it can be removed.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Following on from your patch to remove its use, yes.

Acked-by: Hugh Dickins <hugh@veritas.com>

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
