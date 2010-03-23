Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D8B016B01AC
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 18:45:23 -0400 (EDT)
Received: by pxi32 with SMTP id 32so2068461pxi.1
        for <linux-mm@kvack.org>; Tue, 23 Mar 2010 15:45:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1269347146-7461-10-git-send-email-mel@csn.ul.ie>
References: <1269347146-7461-1-git-send-email-mel@csn.ul.ie>
	 <1269347146-7461-10-git-send-email-mel@csn.ul.ie>
Date: Wed, 24 Mar 2010 07:45:20 +0900
Message-ID: <28c262361003231545i78104ccfr14b68f50dc85bfc2@mail.gmail.com>
Subject: Re: [PATCH 09/11] Add /sys trigger for per-node memory compaction
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 23, 2010 at 9:25 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> This patch adds a per-node sysfs file called compact. When the file is
> written to, each zone in that node is compacted. The intention that this
> would be used by something like a job scheduler in a batch system before
> a job starts so that the job can allocate the maximum number of
> hugepages without significant start-up cost.
>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Acked-by: Rik van Riel <riel@redhat.com>
> Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
