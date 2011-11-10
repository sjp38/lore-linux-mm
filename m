Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 261336B002D
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 18:12:15 -0500 (EST)
Date: Thu, 10 Nov 2011 15:12:11 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Do not stall in synchronous compaction for THP
 allocations
Message-Id: <20111110151211.523fa185.akpm@linux-foundation.org>
In-Reply-To: <20111110161331.GG3083@suse.de>
References: <20111110100616.GD3083@suse.de>
	<20111110142202.GE3083@suse.de>
	<CAEwNFnCRCxrru5rBk7FpypqeL8nD=SY5W3-TaA7Ap5o4CgDSbg@mail.gmail.com>
	<20111110161331.GG3083@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 10 Nov 2011 16:13:31 +0000
Mel Gorman <mgorman@suse.de> wrote:

> This patch once again prevents sync migration for transparent
> hugepage allocations as it is preferable to fail a THP allocation
> than stall.

Who said?  ;) Presumably some people would prefer to get lots of
huge pages for their 1000-hour compute job, and waiting a bit to get
those pages is acceptable.

Do we have the accounting in place for us to be able to determine how
many huge page allocation attempts failed due to this change?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
