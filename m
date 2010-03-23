Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 4549B6B01CA
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 14:34:35 -0400 (EDT)
Date: Tue, 23 Mar 2010 13:33:19 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 07/11] Memory compaction core
In-Reply-To: <20100323181540.GD5870@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1003231332190.10178@router.home>
References: <1269347146-7461-1-git-send-email-mel@csn.ul.ie> <1269347146-7461-8-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.1003231253180.10178@router.home> <20100323181540.GD5870@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 Mar 2010, Mel Gorman wrote:

> I can if you prefer but it's so small, I didn't think it obscured the
> clarity of the patch anyway. I would have somewhat expected the two
> patches to be merged together before going upstream.

It exposes the definitions needed to run __isolate_lru_page(). The
definitions could be useful for other uses of page migrations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
