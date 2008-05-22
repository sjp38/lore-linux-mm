Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp07.in.ibm.com (8.13.1/8.13.1) with ESMTP id m4MAFMgB032502
	for <linux-mm@kvack.org>; Thu, 22 May 2008 15:45:22 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4MAFAG01188038
	for <linux-mm@kvack.org>; Thu, 22 May 2008 15:45:10 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id m4MAEmxL023165
	for <linux-mm@kvack.org>; Thu, 22 May 2008 15:44:48 +0530
Message-ID: <4835477D.1020609@linux.vnet.ibm.com>
Date: Thu, 22 May 2008 15:44:21 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm][PATCH 3/4] cgroup mm owner callback changes to add task
 info (v5)
References: <20080521152921.15001.65968.sendpatchset@localhost.localdomain> <20080521152959.15001.14495.sendpatchset@localhost.localdomain> <20080521211958.ca4f733c.akpm@linux-foundation.org>
In-Reply-To: <20080521211958.ca4f733c.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Pavel Emelianov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Wed, 21 May 2008 20:59:59 +0530 Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> This patch adds an additional field to the mm_owner callbacks. This field
>> is required to get to the mm that changed. Hold mmap_sem in write mode
>> before calling the mm_owner_changed callback
>>
>> ...
>>
>> + * The callbacks are invoked with mmap_sem held in read mode.
> 
> Is that true?
> 
>> +	down_write(&mm->mmap_sem);
>> ...
>>  	cgroup_mm_owner_callbacks(mm->owner, c);
> 
> Looks like write-mode to me?

Yes, obsolete comment. Will fix.

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
