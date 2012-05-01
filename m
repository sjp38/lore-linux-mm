Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id F28636B004D
	for <linux-mm@kvack.org>; Tue,  1 May 2012 17:15:09 -0400 (EDT)
Message-ID: <4FA05251.5060105@redhat.com>
Date: Tue, 01 May 2012 17:14:57 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 2/5] mm + fs: prepare for non-page entries in page cache
References: <1335861713-4573-1-git-send-email-hannes@cmpxchg.org> <1335861713-4573-3-git-send-email-hannes@cmpxchg.org> <20120501120246.83d2ce28.akpm@linux-foundation.org> <20120501201504.GB2112@cmpxchg.org> <20120501132449.30485966.akpm@linux-foundation.org>
In-Reply-To: <20120501132449.30485966.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 05/01/2012 04:24 PM, Andrew Morton wrote:

> That's a pretty significant alteration in the meaning of ->nrpages.
> Did this not have any other effects?

 From what I see (though it's been a long day), ->nrpages
stays the same it is now.

The non-page entries are simply not counted in ->nrpages.

> What does truncate do?  I assume it invalidates shadow page entries in
> the radix tree?  And frees the radix-tree nodes?

Indeed, truncate will get rid of the non-page entries
in the radix tree.  That is why it needs to be called
even if ->nrpages==0.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
