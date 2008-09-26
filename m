Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id m8Q9V5rH016752
	for <linux-mm@kvack.org>; Fri, 26 Sep 2008 19:31:05 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8Q9WIUS3375230
	for <linux-mm@kvack.org>; Fri, 26 Sep 2008 19:32:18 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8Q9WG3T007010
	for <linux-mm@kvack.org>; Fri, 26 Sep 2008 19:32:16 +1000
Message-ID: <48DCAC1D.9020802@linux.vnet.ibm.com>
Date: Fri, 26 Sep 2008 15:02:13 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 1/12] memcg avoid accounting special mappings not on LRU
References: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com> <20080925151307.f9cf352f.kamezawa.hiroyu@jp.fujitsu.com> <48DC9C92.4000408@linux.vnet.ibm.com> <20080926181726.359c77a8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080926181726.359c77a8.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <haveblue@us.ibm.com>, ryov@valinux.co.jp
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Fri, 26 Sep 2008 13:55:54 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> KAMEZAWA Hiroyuki wrote:
>>> There are not-on-LRU pages which can be mapped and they are not worth to
>>> be accounted. (becasue we can't shrink them and need dirty codes to handle
>>> specical case) We'd like to make use of usual objrmap/radix-tree's protcol
>>> and don't want to account out-of-vm's control pages.
>>>
>>> When special_mapping_fault() is called, page->mapping is tend to be NULL 
>>> and it's charged as Anonymous page.
>>> insert_page() also handles some special pages from drivers.
>>>
>>> This patch is for avoiding to account special pages.
>>>
>> Hmm... I am a little concerned that with these changes actual usage will much
>> more than what we report in memory.usage_in_bytes. Why not move them to
>> non-reclaimable LRU list as unevictable pages (once those patches go in, we can
>> push this as well). 
> 
> Because they are not on LRU ...i.e. !PageLRU(page)
> 

I understand.. Thanks for clarifying.. my concern is w.r.t accounting, we
account it in RSS (file RSS).

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
