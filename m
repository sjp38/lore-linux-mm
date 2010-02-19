Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9F0096B0047
	for <linux-mm@kvack.org>; Thu, 18 Feb 2010 20:35:40 -0500 (EST)
Received: by pxi31 with SMTP id 31so4423075pxi.26
        for <linux-mm@kvack.org>; Thu, 18 Feb 2010 17:35:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1266516162-14154-7-git-send-email-mel@csn.ul.ie>
References: <1266516162-14154-1-git-send-email-mel@csn.ul.ie>
	 <1266516162-14154-7-git-send-email-mel@csn.ul.ie>
Date: Fri, 19 Feb 2010 10:35:38 +0900
Message-ID: <28c262361002181735w56ea868fmf778d3421bbecb31@mail.gmail.com>
Subject: Re: [PATCH 06/12] Export unusable free space index via
	/proc/pagetypeinfo
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 19, 2010 at 3:02 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> Unusuable free space index is a measure of external fragmentation that
> takes the allocation size into account. For the most part, the huge page
> size will be the size of interest but not necessarily so it is exported
> on a per-order and per-zone basis via /proc/unusable_index.
>
> The index is a value between 0 and 1. It can be expressed as a
> percentage by multiplying by 100 as documented in
> Documentation/filesystems/proc.txt.
>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
