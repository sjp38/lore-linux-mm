Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id mAB6ONTm013727
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 11:54:23 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mAB6O8tV3412036
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 11:54:08 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id mAB6OMgV022571
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 17:24:23 +1100
Message-ID: <49192510.3060603@linux.vnet.ibm.com>
Date: Tue, 11 Nov 2008 11:54:16 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][mm] [PATCH 3/4] Memory cgroup hierarchical reclaim (v2)
References: <20081108091009.32236.26177.sendpatchset@localhost.localdomain> <20081108091100.32236.89666.sendpatchset@localhost.localdomain> <20081111120607.5ffe8a9c.kamezawa.hiroyu@jp.fujitsu.com> <49190E5F.2050109@linux.vnet.ibm.com> <20081111140113.fc24d317.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081111140113.fc24d317.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
>>
> please see mem+swap controller's refcnt-to-memcg for delaying free of memcg.
> it will be a hint.
> 

I'll integrate with those patches later. I see a memcg->swapref, but we don't
need to delay deletion for last_scanned_child, we need to make sure that the
parent does not have any invalid entries.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
