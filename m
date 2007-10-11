Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id l9BC6IGU001327
	for <linux-mm@kvack.org>; Thu, 11 Oct 2007 22:06:18 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9BC6ICt4321482
	for <linux-mm@kvack.org>; Thu, 11 Oct 2007 22:06:19 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9BC3QcI015748
	for <linux-mm@kvack.org>; Thu, 11 Oct 2007 22:03:26 +1000
Message-ID: <470E1194.6060001@linux.vnet.ibm.com>
Date: Thu, 11 Oct 2007 17:35:40 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH][BUGFIX][for -mm] Misc fix for memory cgroup [5/5] ---
 fix page migration under memory controller
References: <20071011135345.5d9a4c06.kamezawa.hiroyu@jp.fujitsu.com> <20071011140220.a62daf1a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071011140220.a62daf1a.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> +
> +static inline void
> +mem_cgroup_page_migration(struct page *page, struct page *newpage);

Typo, the semicolon needs to go :-)

> +{
> +}
> +
> +

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
