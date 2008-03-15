Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id m2F6GFqi009917
	for <linux-mm@kvack.org>; Sat, 15 Mar 2008 17:16:15 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2F6KCJD181784
	for <linux-mm@kvack.org>; Sat, 15 Mar 2008 17:20:13 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2F6GTnb001357
	for <linux-mm@kvack.org>; Sat, 15 Mar 2008 17:16:29 +1100
Message-ID: <47DB6980.8010308@linux.vnet.ibm.com>
Date: Sat, 15 Mar 2008 11:45:28 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 0/7] memcg: radix-tree page_cgroup
References: <20080314185954.5cd51ff6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080314185954.5cd51ff6.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, xemul@openvz.org, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> This is a patch set for implemening page_cgroup under radix-tree.
> against 2.6.25-rc5-mm1.

Hi, KAMEZAWA-San,

I am building and applying all the patches one-by-one (just started). I'll get
back soon. Thanks for looking into this

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
