Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E73AE62007E
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 20:06:24 -0400 (EDT)
Date: Tue, 6 Apr 2010 17:06:13 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 12/14] Add a tunable that decides when memory should be
 compacted and when it should be reclaimed
Message-Id: <20100406170613.9b80c7ea.akpm@linux-foundation.org>
In-Reply-To: <1270224168-14775-13-git-send-email-mel@csn.ul.ie>
References: <1270224168-14775-1-git-send-email-mel@csn.ul.ie>
	<1270224168-14775-13-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri,  2 Apr 2010 17:02:46 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> The kernel applies some heuristics when deciding if memory should be
> compacted or reclaimed to satisfy a high-order allocation. One of these
> is based on the fragmentation. If the index is below 500, memory will
> not be compacted. This choice is arbitrary and not based on data. To
> help optimise the system and set a sensible default for this value, this
> patch adds a sysctl extfrag_threshold. The kernel will only compact
> memory if the fragmentation index is above the extfrag_threshold.

Was this the most robust, reliable, no-2am-phone-calls thing we could
have done?

What about, say, just doing a bit of both until something worked?  For
extra smarts we could remember what worked best last time, and make
ourselves more likely to try that next time.

Or whatever, but extfrag_threshold must die!  And replacing it with a
hardwired constant doesn't count ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
