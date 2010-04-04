Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 8B1786B01E3
	for <linux-mm@kvack.org>; Sun,  4 Apr 2010 10:19:12 -0400 (EDT)
Date: Sun, 4 Apr 2010 23:19:06 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH]vmscan: handle underflow for get_scan_ratio
In-Reply-To: <20100402092441.GA21100@sli10-desk.sh.intel.com>
References: <20100402181307.6470.A69D9226@jp.fujitsu.com> <20100402092441.GA21100@sli10-desk.sh.intel.com>
Message-Id: <20100404231558.7E00.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Wu, Fengguang" <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

> On Fri, Apr 02, 2010 at 05:14:38PM +0800, KOSAKI Motohiro wrote:
> > > > > This patch makes a lot of sense than previous. however I think <1% anon ratio
> > > > > shouldn't happen anyway because file lru doesn't have reclaimable pages.
> > > > > <1% seems no good reclaim rate.
> > > > 
> > > > Oops, the above mention is wrong. sorry. only 1 page is still too big.
> > > > because under streaming io workload, the number of scanning anon pages should
> > > > be zero. this is very strong requirement. if not, backup operation will makes
> > > > a lot of swapping out.
> > > Sounds there is no big impact for the workload which you mentioned with the patch.
> > > please see below descriptions.
> > > I updated the description of the patch as fengguang suggested.
> > 
> > Umm.. sorry, no.
> > 
> > "one fix but introduce another one bug" is not good deal. instead, 
> > I'll revert the guilty commit at first as akpm mentioned.
> Even we revert the commit, the patch still has its benefit, as it increases
> calculation precision, right?

no, you shouldn't ignore the regression case.

If we can remove the streaming io corner case by another patch, this patch
can be considered to merge.

thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
