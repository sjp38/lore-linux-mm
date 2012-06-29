Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 0FE466B005A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 23:52:02 -0400 (EDT)
Date: Fri, 29 Jun 2012 00:51:24 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v2 0/4] make balloon pages movable by compaction
Message-ID: <20120629035123.GA1763@t510.redhat.com>
References: <cover.1340916058.git.aquini@redhat.com>
 <4FED06C8.1090003@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FED06C8.1090003@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On Fri, Jun 29, 2012 at 10:37:12AM +0900, Minchan Kim wrote:
> Hi Rafael,
> 
> On 06/29/2012 06:49 AM, Rafael Aquini wrote:
> 
> > This patchset follows the main idea discussed at 2012 LSFMMS section:
> > "Ballooning for transparent huge pages" -- http://lwn.net/Articles/490114/
> 
> 
> Could you summarize the problem, solution instead of link URL in cover-letter?
> IIUC, the problem is that it is hard to get contiguous memory in guest-side 
> after ballooning happens because guest-side memory could be very fragmented
> by ballooned page. It makes THP page allocation of guest-side very poor success ratio.
> 
> The solution is that when memory ballooning happens, we allocates ballooned page
> as a movable page in guest-side because they can be migrated easily so compaction of
> guest-side could put together them into either side so that we can get contiguous memory.
> For it, compaction should be aware of ballooned page.
> 
> Right?
>
Yes, you surely got it correct, sir. 

Thanks Minchan, for taking time to provide me such feedback. I'll rework commit
messages to make them more elucidative, yet concise for the next submission.

Please, let me know if you have other concerns I shall be addressing here.

Best regards!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
