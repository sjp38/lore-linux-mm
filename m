Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id E563C6B0169
	for <linux-mm@kvack.org>; Fri, 29 Jul 2011 04:23:23 -0400 (EDT)
Received: by yxn22 with SMTP id 22so2696912yxn.14
        for <linux-mm@kvack.org>; Fri, 29 Jul 2011 01:23:22 -0700 (PDT)
Date: Fri, 29 Jul 2011 17:23:13 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH v4 00/10] Prevent LRU churning
Message-ID: <20110729082313.GA1843@barrios-desktop>
References: <cover.1309787991.git.minchan.kim@gmail.com>
 <20110727131650.ad30a331.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110727131650.ad30a331.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>

On Wed, Jul 27, 2011 at 01:16:50PM -0700, Andrew Morton wrote:
> On Mon,  4 Jul 2011 23:04:33 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
> 
> > Test result is following as.
> > 
> > 1) Elapased time 10GB file decompressed.
> > Old			inorder			inorder + pagevec flush[10/10]
> > 01:47:50.88		01:43:16.16		01:40:27.18
> > 
> > 2) failure of inorder lru
> > For test, it isolated 375756 pages. Only 45875 pages(12%) are put backed to
> > out-of-order(ie, head of LRU) Others, 329963 pages(88%) are put backed to in-order
> > (ie, position of old page in LRU).
> 
> I'm getting more and more worried about how complex MM is becoming and
> this patchset doesn't take us in a helpful direction :(

Hmm. I think it's not too complicated stuff. :(
But I understand your concern enoughly.

> 
> But it's hard to argue with numbers like that.  Please respin patches 6-10?

Of course, but it would be rather late due to my business and other interesting features.
I will try to get a new data point in next version.

Thanks, Andrew.

> 
> 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
