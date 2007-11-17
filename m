Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lAH93onG005305
	for <linux-mm@kvack.org>; Sat, 17 Nov 2007 04:03:50 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.6) with ESMTP id lAH93oKm334926
	for <linux-mm@kvack.org>; Sat, 17 Nov 2007 04:03:50 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAH93nJC006314
	for <linux-mm@kvack.org>; Sat, 17 Nov 2007 04:03:49 -0500
Message-ID: <473EAE72.3080804@linux.vnet.ibm.com>
Date: Sat, 17 Nov 2007 14:33:46 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] memory controller per zone patches take 2 [1/10]
 add scan_global_lru() macro
References: <20071116191107.46dd523a.kamezawa.hiroyu@jp.fujitsu.com> <20071116191459.dcd71a3d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071116191459.dcd71a3d.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "containers@lists.osdl.org" <containers@lists.osdl.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> add macro scan_global_lru().
> 
> This is used to detect which scan_control scans global lru or
> mem_cgroup lru. And compiled to be static value (1) when 
> memory controller is not configured. (maybe good for compiler)
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Looks good to me

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
