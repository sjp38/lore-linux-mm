Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B5BB16B01FF
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 05:24:44 -0400 (EDT)
Date: Fri, 2 Apr 2010 17:24:41 +0800
From: Shaohua Li <shaohua.li@intel.com>
Subject: Re: [PATCH]vmscan: handle underflow for get_scan_ratio
Message-ID: <20100402092441.GA21100@sli10-desk.sh.intel.com>
References: <20100331145030.03A1.A69D9226@jp.fujitsu.com>
 <20100402065052.GA28027@sli10-desk.sh.intel.com>
 <20100402181307.6470.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100402181307.6470.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Wu, Fengguang" <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Fri, Apr 02, 2010 at 05:14:38PM +0800, KOSAKI Motohiro wrote:
> > > > This patch makes a lot of sense than previous. however I think <1% anon ratio
> > > > shouldn't happen anyway because file lru doesn't have reclaimable pages.
> > > > <1% seems no good reclaim rate.
> > > 
> > > Oops, the above mention is wrong. sorry. only 1 page is still too big.
> > > because under streaming io workload, the number of scanning anon pages should
> > > be zero. this is very strong requirement. if not, backup operation will makes
> > > a lot of swapping out.
> > Sounds there is no big impact for the workload which you mentioned with the patch.
> > please see below descriptions.
> > I updated the description of the patch as fengguang suggested.
> 
> Umm.. sorry, no.
> 
> "one fix but introduce another one bug" is not good deal. instead, 
> I'll revert the guilty commit at first as akpm mentioned.
Even we revert the commit, the patch still has its benefit, as it increases
calculation precision, right?

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
