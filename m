Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 2975B6B005A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 21:36:59 -0400 (EDT)
Message-ID: <4FED06C8.1090003@kernel.org>
Date: Fri, 29 Jun 2012 10:37:12 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/4] make balloon pages movable by compaction
References: <cover.1340916058.git.aquini@redhat.com>
In-Reply-To: <cover.1340916058.git.aquini@redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

Hi Rafael,

On 06/29/2012 06:49 AM, Rafael Aquini wrote:

> This patchset follows the main idea discussed at 2012 LSFMMS section:
> "Ballooning for transparent huge pages" -- http://lwn.net/Articles/490114/


Could you summarize the problem, solution instead of link URL in cover-letter?
IIUC, the problem is that it is hard to get contiguous memory in guest-side 
after ballooning happens because guest-side memory could be very fragmented
by ballooned page. It makes THP page allocation of guest-side very poor success ratio.

The solution is that when memory ballooning happens, we allocates ballooned page
as a movable page in guest-side because they can be migrated easily so compaction of
guest-side could put together them into either side so that we can get contiguous memory.
For it, compaction should be aware of ballooned page.

Right?

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
