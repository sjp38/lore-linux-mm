Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id l9GIfaFN025738
	for <linux-mm@kvack.org>; Wed, 17 Oct 2007 04:41:36 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9GIfQr51319142
	for <linux-mm@kvack.org>; Wed, 17 Oct 2007 04:41:26 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9GIfASS000636
	for <linux-mm@kvack.org>; Wed, 17 Oct 2007 04:41:10 +1000
Message-ID: <471505B6.4030806@linux.vnet.ibm.com>
Date: Wed, 17 Oct 2007 00:10:54 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] memory cgroup enhancements [0/5] intro
References: <20071016191949.cd50f12f.kamezawa.hiroyu@jp.fujitsu.com> <471500EC.1080502@linux.vnet.ibm.com> <20071016112843.e4b8ebe3.akpm@linux-foundation.org>
In-Reply-To: <20071016112843.e4b8ebe3.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, containers@lists.osdl.org, yamamoto@valinux.co.jp
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Tue, 16 Oct 2007 23:50:28 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>>> [1/5] ... force_empty patch
>>> [2/5] ... remember page is charged as page-cache patch
>>> [3/5] ... remember page is on which list patch
>>> [4/5] ... memory cgroup statistics patch
>>> [5/5] ... show statistics patch
>>>
>>> tested on x86-64/fake-NUMA + CONFIG_PREEMPT=y/n (for testing preempt_disable())
>>>
>>> Any comments are welcome.
>>>
>> Hi, KAMEZAWA-San,
>>
>> I would prefer these patches to go in once the fixes that you've posted
>> earlier have gone in (the migration fix series). I am yet to test the
>> migration fix per-se, but the series seemed quite fine to me. Andrew
>> could you please pick it up.
> 
> It's in my backlog somewhere.  I'm not paying much attention to things
> which don't look like 2.6.24 material at present...

Aah.. That makes sense.. Thanks for clarifying.

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
