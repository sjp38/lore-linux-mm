Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 3A85C6B0141
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 15:43:25 -0400 (EDT)
Date: Mon, 20 Jun 2011 21:43:21 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/3] mm: completely disable THP by
 transparent_hugepage=never
Message-ID: <20110620194321.GI20843@redhat.com>
References: <1308587683-2555-1-git-send-email-amwang@redhat.com>
 <20110620165035.GE20843@redhat.com>
 <4DFF7CDD.308@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4DFF7CDD.308@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Tue, Jun 21, 2011 at 01:01:17AM +0800, Cong Wang wrote:
> Without this patch, THP is still initialized (although khugepaged is not started),
> that is what I don't want to see when I pass "transparent_hugepage=never",
> because "never" for me means THP is totally unseen, even not initialized.

The ram saving by not registering in sysfs is not worth the loss of
generic functionality. You can try to make the hash and slab
khugepaged allocations more dynamic if you want to microoptimize for
RAM usage, that I wouldn't be against if you find a way to do it
simply and without much complexity (and .text) added. But likely there
are other places to optimize that may introduce less tricks and would
give you a bigger saving than ~8kbytes, it's up to you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
