Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 6F0A96B01EF
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 21:36:39 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o361aa2J016813
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 6 Apr 2010 10:36:36 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D2AA45DE4E
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 10:36:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F8171EF081
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 10:36:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4633AE38001
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 10:36:36 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E8DEAE38009
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 10:36:32 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH]vmscan: handle underflow for get_scan_ratio
In-Reply-To: <20100406012536.GB18672@sli10-desk.sh.intel.com>
References: <20100404231558.7E00.A69D9226@jp.fujitsu.com> <20100406012536.GB18672@sli10-desk.sh.intel.com>
Message-Id: <20100406103500.7E2D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  6 Apr 2010 10:36:32 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Wu, Fengguang" <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

> On Sun, Apr 04, 2010 at 10:19:06PM +0800, KOSAKI Motohiro wrote:
> > > On Fri, Apr 02, 2010 at 05:14:38PM +0800, KOSAKI Motohiro wrote:
> > > > > > > This patch makes a lot of sense than previous. however I think <1% anon ratio
> > > > > > > shouldn't happen anyway because file lru doesn't have reclaimable pages.
> > > > > > > <1% seems no good reclaim rate.
> > > > > > 
> > > > > > Oops, the above mention is wrong. sorry. only 1 page is still too big.
> > > > > > because under streaming io workload, the number of scanning anon pages should
> > > > > > be zero. this is very strong requirement. if not, backup operation will makes
> > > > > > a lot of swapping out.
> > > > > Sounds there is no big impact for the workload which you mentioned with the patch.
> > > > > please see below descriptions.
> > > > > I updated the description of the patch as fengguang suggested.
> > > > 
> > > > Umm.. sorry, no.
> > > > 
> > > > "one fix but introduce another one bug" is not good deal. instead, 
> > > > I'll revert the guilty commit at first as akpm mentioned.
> > > Even we revert the commit, the patch still has its benefit, as it increases
> > > calculation precision, right?
> > 
> > no, you shouldn't ignore the regression case.
> I don't think this is serious. In my calculation, there is only 1 page swapped out
> for 6G anonmous memory. 1 page should haven't any performance impact.

there is. I had received exactly opposite claim. because shrink_zone()
is not called only once. it is called very much time.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
