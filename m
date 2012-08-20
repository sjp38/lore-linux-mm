Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 075706B005D
	for <linux-mm@kvack.org>; Mon, 20 Aug 2012 15:52:56 -0400 (EDT)
Date: Mon, 20 Aug 2012 19:52:55 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/5] mempolicy: fix a race in shared_policy_replace()
In-Reply-To: <1345480594-27032-4-git-send-email-mgorman@suse.de>
Message-ID: <00000139459858e2-456fe4a0-e238-47cc-a057-d87d6a193b6a-000000@email.amazonses.com>
References: <1345480594-27032-1-git-send-email-mgorman@suse.de> <1345480594-27032-4-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Jones <davej@redhat.com>, Ben Hutchings <ben@decadent.org.uk>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Mon, 20 Aug 2012, Mel Gorman wrote:

> Kosaki's original patch for this problem was to allocate an sp node and policy
> within shared_policy_replace and initialise it when the lock is reacquired. I
> was not keen on this approach because it partially duplicates sp_alloc(). As
> the paths were sp->lock is taken are not that performance critical this
> patch converts sp->lock to sp->mutex so it can sleep when calling sp_alloc().

Reviewed-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
