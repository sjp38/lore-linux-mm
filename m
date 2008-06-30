Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id m5U8Bg4F031820
	for <linux-mm@kvack.org>; Mon, 30 Jun 2008 18:11:42 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5U8BAU5082624
	for <linux-mm@kvack.org>; Mon, 30 Jun 2008 18:11:12 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5U8B9b6014449
	for <linux-mm@kvack.org>; Mon, 30 Jun 2008 18:11:09 +1000
Message-ID: <48689527.7070403@linux.vnet.ibm.com>
Date: Mon, 30 Jun 2008 13:41:19 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC 5/5] Memory controller soft limit reclaim on contention
References: <20080630161657.37E3.KOSAKI.MOTOHIRO@jp.fujitsu.com> <48688FCB.9040205@linux.vnet.ibm.com> <20080630165125.37E6.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080630165125.37E6.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
> yes, memcg used only one page.
> but mem_cgroup_reclaim_on_contention() reclaim for generic alloc_pages(), instead for memcg.
> we can't assume memcg usage.
> isn't it?

Yes, but the reclaim is from memcg pages (memcg groups that are over their soft
limit). I am not sure if I understand your point? If your claim is that we don't
free up pages of at-least order (as desired by __alloc_pages_internal()), that
is correct. We can ensure that we do a pass over memcg and generic zone LRU.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
