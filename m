Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E5F7E6B01F1
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 21:25:39 -0400 (EDT)
Date: Tue, 6 Apr 2010 09:25:36 +0800
From: Shaohua Li <shaohua.li@intel.com>
Subject: Re: [PATCH]vmscan: handle underflow for get_scan_ratio
Message-ID: <20100406012536.GB18672@sli10-desk.sh.intel.com>
References: <20100402181307.6470.A69D9226@jp.fujitsu.com>
 <20100402092441.GA21100@sli10-desk.sh.intel.com>
 <20100404231558.7E00.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100404231558.7E00.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Wu, Fengguang" <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Sun, Apr 04, 2010 at 10:19:06PM +0800, KOSAKI Motohiro wrote:
> > On Fri, Apr 02, 2010 at 05:14:38PM +0800, KOSAKI Motohiro wrote:
> > > > > > This patch makes a lot of sense than previous. however I think <1% anon ratio
> > > > > > shouldn't happen anyway because file lru doesn't have reclaimable pages.
> > > > > > <1% seems no good reclaim rate.
> > > > > 
> > > > > Oops, the above mention is wrong. sorry. only 1 page is still too big.
> > > > > because under streaming io workload, the number of scanning anon pages should
> > > > > be zero. this is very strong requirement. if not, backup operation will makes
> > > > > a lot of swapping out.
> > > > Sounds there is no big impact for the workload which you mentioned with the patch.
> > > > please see below descriptions.
> > > > I updated the description of the patch as fengguang suggested.
> > > 
> > > Umm.. sorry, no.
> > > 
> > > "one fix but introduce another one bug" is not good deal. instead, 
> > > I'll revert the guilty commit at first as akpm mentioned.
> > Even we revert the commit, the patch still has its benefit, as it increases
> > calculation precision, right?
> 
> no, you shouldn't ignore the regression case.
I don't think this is serious. In my calculation, there is only 1 page swapped out
for 6G anonmous memory. 1 page should haven't any performance impact.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
