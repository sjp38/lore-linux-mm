Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id m96HF4i8017686
	for <linux-mm@kvack.org>; Tue, 7 Oct 2008 04:15:04 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m96HFdgd1769726
	for <linux-mm@kvack.org>; Tue, 7 Oct 2008 04:15:41 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m96HFcX7004463
	for <linux-mm@kvack.org>; Tue, 7 Oct 2008 04:15:38 +1100
Message-ID: <48EA47B7.8010304@linux.vnet.ibm.com>
Date: Mon, 06 Oct 2008 22:45:35 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] memcg: ready-to-go series (was memcg update v6)
References: <20080929191927.caabec89.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080929191927.caabec89.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "xemul@openvz.org" <xemul@openvz.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Cut out 4 patches from memcg update v5 series.
> (Then, this is a part of v6)
> 
> I think we got some agreement on these 4.
> 
> please ack if ok.
> 
> [1/4] ...  account swap under lock
> [2/4] ...  make page->mapping to be NULL before uncharge cache.
> [3/4] ...  avoid accounting not-on-LRU pages.
> [4/4] ...  optimize cpu stat
> 
> I still have 6 patches but it's under test and needs review and discussion.

Hi, Andrew,

Could you please pick this patchset, following it is a very important set of
patches that remove struct page's page_cgroup member.


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
