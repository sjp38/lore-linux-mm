Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp02.in.ibm.com (8.13.1/8.13.1) with ESMTP id m2J3GdhO007286
	for <linux-mm@kvack.org>; Wed, 19 Mar 2008 08:46:39 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2J3Gcgr1306802
	for <linux-mm@kvack.org>; Wed, 19 Mar 2008 08:46:39 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id m2J3Gco6026696
	for <linux-mm@kvack.org>; Wed, 19 Mar 2008 03:16:38 GMT
Date: Wed, 19 Mar 2008 08:44:45 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 5/7] radix-tree page cgroup
Message-ID: <20080319031445.GF24473@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20080314185954.5cd51ff6.kamezawa.hiroyu@jp.fujitsu.com> <20080314191733.eff648f8.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20080314191733.eff648f8.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, xemul@openvz.org, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2008-03-14 19:17:33]:

> +		if (node_state(nid, N_NORMAL_MEMORY)

Small Typo - missing parenthesis

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
