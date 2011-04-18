Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 40C9B900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 08:33:04 -0400 (EDT)
Date: Mon, 18 Apr 2011 22:32:51 +1000
From: NeilBrown <neilb@suse.de>
Subject: Re: [PATCH 12/12] mm: Throttle direct reclaimers if PF_MEMALLOC
 reserves are low and swap is backed by network storage
Message-ID: <20110418223251.7ab148bb@notabene.brown>
In-Reply-To: <1302777698-28237-13-git-send-email-mgorman@suse.de>
References: <1302777698-28237-1-git-send-email-mgorman@suse.de>
	<1302777698-28237-13-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Thu, 14 Apr 2011 11:41:38 +0100 Mel Gorman <mgorman@suse.de> wrote:

> If swap is backed by network storage such as NBD, there is a risk that a
> large number of reclaimers can hang the system by consuming all
> PF_MEMALLOC reserves. To avoid these hangs, the administrator must tune
> min_free_kbytes in advance. This patch will throttle direct reclaimers
> if half the PF_MEMALLOC reserves are in use as the system is at risk of
> hanging. A message will be displayed so the administrator knows that
> min_free_kbytes should be tuned to a higher value to avoid the
> throttling in the future.
> 

(I knew there was something else).

I understand that there are suggestions that direct reclaim should always be
serialised as this reduces lock contention and improve data patterns (or
something like that).

Would that make this patch redundant?  Or does this provide some extra
guarantee that the other proposal would not?

Thanks again,

NeilBrown

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
