Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5D0649000C2
	for <linux-mm@kvack.org>; Wed,  6 Jul 2011 19:44:57 -0400 (EDT)
Date: Wed, 6 Jul 2011 16:44:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 01/14] mm: Serialize access to min_free_kbytes
Message-Id: <20110706164447.d571051a.akpm@linux-foundation.org>
In-Reply-To: <1308575540-25219-2-git-send-email-mgorman@suse.de>
References: <1308575540-25219-1-git-send-email-mgorman@suse.de>
	<1308575540-25219-2-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Mon, 20 Jun 2011 14:12:07 +0100
Mel Gorman <mgorman@suse.de> wrote:

> There is a race between the min_free_kbytes sysctl, memory hotplug
> and transparent hugepage support enablement.  Memory hotplug uses a
> zonelists_mutex to avoid a race when building zonelists. Reuse it to
> serialise watermark updates.

This patch appears to be a standalone fix, unrelated to the overall
patch series?

How does one trigger the race and what happens when it hits, btw?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
