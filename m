Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 7DA6A6B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 03:36:38 -0400 (EDT)
Date: Mon, 5 Aug 2013 16:36:47 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 17/18] mm, hugetlb: retry if we fail to allocate a
 hugepage with use_reserve
Message-ID: <20130805073647.GD27240@lge.com>
References: <1375075929-6119-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1375075929-6119-18-git-send-email-iamjoonsoo.kim@lge.com>
 <20130729072823.GD29970@voom.fritz.box>
 <20130731053753.GM2548@lge.com>
 <20130803104302.GC19115@voom.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130803104302.GC19115@voom.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Gibson <david@gibson.dropbear.id.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

> Any mapping that doesn't use the reserved pool, not just
> MAP_NORESERVE.  For example, if a process makes a MAP_PRIVATE mapping,
> then fork()s then the mapping is instantiated in the child, that will
> not draw from the reserved pool.
> 
> > Should we ensure them to allocate the last hugepage?
> > They map a region with MAP_NORESERVE, so don't assume that their requests
> > always succeed.
> 
> If the pages are available, people get cranky if it fails for no
> apparent reason, MAP_NORESERVE or not.  They get especially cranky if
> it sometimes fails and sometimes doesn't due to a race condition.

Hello,

Hmm... Okay. I will try to implement another way to protect race condition.
Maybe it is the best to use a table mutex :)
Anyway, please give me a time, guys.

Really thank you for pointing that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
