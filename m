Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id mAH4oWTM023229
	for <linux-mm@kvack.org>; Mon, 17 Nov 2008 15:50:33 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mAH4o5qu273380
	for <linux-mm@kvack.org>; Mon, 17 Nov 2008 15:50:05 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mAH4o4GQ013071
	for <linux-mm@kvack.org>; Mon, 17 Nov 2008 15:50:05 +1100
Message-ID: <4920F7F7.6050601@linux.vnet.ibm.com>
Date: Mon, 17 Nov 2008 10:19:59 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [mm] [PATCH 4/4] Memory cgroup hierarchy feature selector (v4)
References: <20081116081034.25166.7586.sendpatchset@balbir-laptop> <20081116081105.25166.54820.sendpatchset@balbir-laptop> <4920F70D.9030100@cn.fujitsu.com>
In-Reply-To: <4920F70D.9030100@cn.fujitsu.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Li Zefan wrote:
>> +	/*
>> +	 * If parent's use_hiearchy is set, we can't make any modifications
>> +	 * in the child subtrees. If it is unset, then the change can
>> +	 * occur, provided the current cgroup has no children.
>> +	 *
>> +	 * For the root cgroup, parent_mem is NULL, we allow value to be
>> +	 * set if there are no children.
>> +	 */
>> +	if (!parent_mem || (!parent_mem->use_hierarchy &&
>> +				(val == 1 || val == 0))) {
> 
> Should be :
> 
> if ((!parent_mem || !parent_mem->use_hierarchy) &&
>     (val == 1 || val == 0)) {

Yes, we need to validate values for root cgroup as well. Thanks for the comments

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
