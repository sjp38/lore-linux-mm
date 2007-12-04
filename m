Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lB4GWHcJ005022
	for <linux-mm@kvack.org>; Tue, 4 Dec 2007 11:32:17 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lB4GWH6l491704
	for <linux-mm@kvack.org>; Tue, 4 Dec 2007 11:32:17 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lB4GWG1V020512
	for <linux-mm@kvack.org>; Tue, 4 Dec 2007 11:32:17 -0500
Message-ID: <47558105.1050603@linux.vnet.ibm.com>
Date: Tue, 04 Dec 2007 22:02:05 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][for -mm] memory controller enhancements for reclaiming
 take2 [3/8] define free_mem_cgroup_per_zone_info
References: <20071203183355.0061ddeb.kamezawa.hiroyu@jp.fujitsu.com> <20071203183719.b929cb92.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071203183719.b929cb92.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "riel@redhat.com" <riel@redhat.com>, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Now allocation of per_zone of mem_controller is done by
> alloc_mem_cgroup_per_zone_info(). Then it will be good to use
> free_mem_cgroup_per_zone_info() for maintainance.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Looks good

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

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
