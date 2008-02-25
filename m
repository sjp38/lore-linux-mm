Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id m1P3PPUO008274
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 14:25:25 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1P3R01Q281154
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 14:27:00 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1P3NMJo007562
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 14:23:22 +1100
Message-ID: <47C23375.90007@linux.vnet.ibm.com>
Date: Mon, 25 Feb 2008 08:48:13 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] Clarify mem_cgroup lock handling and avoid races.
References: <20080219215431.1aa9fa8a.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0802191449490.6254@blonde.site> <20080220.152753.98212356.taka@valinux.co.jp> <20080220155049.094056ac.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0802220916290.18145@blonde.site> <47BEAEA9.10801@linux.vnet.ibm.com> <Pine.LNX.4.64.0802221144210.379@blonde.site> <47BEBFE5.9000905@linux.vnet.ibm.com> <Pine.LNX.4.64.0802221249540.6674@blonde.site>
In-Reply-To: <Pine.LNX.4.64.0802221249540.6674@blonde.site>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hirokazu Takahashi <taka@valinux.co.jp>, linux-mm@kvack.org, yamamoto@valinux.co.jp, riel@redhat.com
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> On Fri, 22 Feb 2008, Balbir Singh wrote:
>> Hugh Dickins wrote:
>>> I'd hoped to send out my series last night, but was unable to get
>>> quite that far, sorry, and haven't tested the page migration paths yet.
>>> The total is not unlike what I already showed, but plus Hirokazu-san's
>>> patch and minus shmem's NULL page and minus my rearrangement of
>>> mem_cgroup_charge_common.
>> Do let me know when you'll have a version to test, I can run LTP, LTP stress
>> and other tests overnight.
> 
> This is the rollup, I'll try hard not to depart from this later without
> good reason - thanks, Hugh

Hi, Hugh,

Thanks, I'll test these against 2.6.25-rc3.

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
