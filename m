Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 426C66B01FD
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 05:14:44 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o329EeZ7007760
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 2 Apr 2010 18:14:41 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C11D45DE4E
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 18:14:40 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 029FE45DE4F
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 18:14:40 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B2F2DE38002
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 18:14:39 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 62507E08007
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 18:14:39 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH]vmscan: handle underflow for get_scan_ratio
In-Reply-To: <20100402065052.GA28027@sli10-desk.sh.intel.com>
References: <20100331145030.03A1.A69D9226@jp.fujitsu.com> <20100402065052.GA28027@sli10-desk.sh.intel.com>
Message-Id: <20100402181307.6470.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri,  2 Apr 2010 18:14:38 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Wu, Fengguang" <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

> > > This patch makes a lot of sense than previous. however I think <1% anon ratio
> > > shouldn't happen anyway because file lru doesn't have reclaimable pages.
> > > <1% seems no good reclaim rate.
> > 
> > Oops, the above mention is wrong. sorry. only 1 page is still too big.
> > because under streaming io workload, the number of scanning anon pages should
> > be zero. this is very strong requirement. if not, backup operation will makes
> > a lot of swapping out.
> Sounds there is no big impact for the workload which you mentioned with the patch.
> please see below descriptions.
> I updated the description of the patch as fengguang suggested.

Umm.. sorry, no.

"one fix but introduce another one bug" is not good deal. instead, 
I'll revert the guilty commit at first as akpm mentioned.

thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
