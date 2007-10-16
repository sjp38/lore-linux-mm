Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id l9GL40V4021477
	for <linux-mm@kvack.org>; Wed, 17 Oct 2007 07:04:00 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9GL40Ca643290
	for <linux-mm@kvack.org>; Wed, 17 Oct 2007 07:04:01 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9GL18Iq017179
	for <linux-mm@kvack.org>; Wed, 17 Oct 2007 07:01:08 +1000
Message-ID: <47152720.2020007@linux.vnet.ibm.com>
Date: Wed, 17 Oct 2007 02:33:28 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [BUGFIX][RFC][PATCH][only -mm] FIX memory leak in memory cgroup
 vs. page migration [0/1]
References: <20071002183031.3352be6a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071002183031.3352be6a.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
[snip]
> # migrate_test mmaps 512Mfile and call system call move_pages(). and sleep.
> [root@drpq kamezawa]# ./migrate_test 512Mfile 1 &
> [1] 4108

This step fails for me. I get an -ENOENT error from the utility you sent
me. As I look through the migration code more (It's too late for me to
double check), but it seems that only pages mapped in the process are
migrated. cat(1) won't really map anything. Am I missing some of the
reproduction steps?

> #At the end of migration,
> [root@drpq kamezawa]# cat /opt/mem_control/group_?/memory.usage_in_bytes
> 539738112
> 537706496
> 
> #Wow, charge is twice ;)


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
