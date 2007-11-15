Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lAF6Q3Id004205
	for <linux-mm@kvack.org>; Thu, 15 Nov 2007 01:26:03 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lAF6Pve4118854
	for <linux-mm@kvack.org>; Wed, 14 Nov 2007 23:26:02 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAF6Pvr8015580
	for <linux-mm@kvack.org>; Wed, 14 Nov 2007 23:25:57 -0700
Message-ID: <473BE66E.2000707@linux.vnet.ibm.com>
Date: Thu, 15 Nov 2007 11:55:50 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][ for -mm] memory controller enhancements for NUMA [0/10]
 introduction
References: <20071114173950.92857eaa.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071114173950.92857eaa.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Hi,
> 
> This is a patch-set for memory controlelr on NUMA. 
> patches are
> 
> 1. record nid/zid on page_cgroup struct
> 2. record per-zone active/inactive
> 3-9 Patches for isolate global-lru reclaiming and memory controller reclaming
> 10. implements per-zone LRU on memory controller.
> 
> now this is just RFC.
> 
> Tested on 
>   2.6.24-rc2-mm1 + x86_64/fake-NUMA( # of nodes = 3)
> 
> I did test with numactl under memory limitation.
>  % numactl -i 0,1,2 dd if=.....
> 
> It seems per-zone-lru works well.
> 
> I'd like to do test on ia64/real-NUMA when I have a chance.
> 
> Any comments are welcome.
> 

Hi, KAMEZAWA-San,

Thanks for the patchset, I'll review it and get back. I'd
also try and get some testing done on it.

> Thanks,
>  -kame
> 

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
