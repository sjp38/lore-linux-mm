Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp02.in.ibm.com (8.13.1/8.13.1) with ESMTP id m279HcTc026173
	for <linux-mm@kvack.org>; Fri, 7 Mar 2008 14:47:38 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m279HbFc1229002
	for <linux-mm@kvack.org>; Fri, 7 Mar 2008 14:47:37 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id m279HbEW017394
	for <linux-mm@kvack.org>; Fri, 7 Mar 2008 09:17:37 GMT
Message-ID: <47D107BC.2010809@linux.vnet.ibm.com>
Date: Fri, 07 Mar 2008 14:45:40 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] Make memory resource control aware of boot options (v2)
References: <20080307085735.25567.314.sendpatchset@localhost.localdomain> <20080307085746.25567.71595.sendpatchset@localhost.localdomain> <20080307010649.74f51535.akpm@linux-foundation.org> <20080307010819.85b194c9.akpm@linux-foundation.org>
In-Reply-To: <20080307010819.85b194c9.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Menage <menage@google.com>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Fri, 7 Mar 2008 01:06:49 -0800 Andrew Morton <akpm@linux-foundation.org> wrote:
> 
>> On Fri, 07 Mar 2008 14:27:46 +0530 Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>
>>> +	if (mem_cgroup_subsys.disabled)
>> My copy of `struct cgroup_subsys' doesn't have a .disabled?
>>
> 
> Ah.  You didn't sequence-number the patches, and they arrived out-of-order. 
> tsk.
> 

Oops -- sorry about that.

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
