Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id l92FaXMe016171
	for <linux-mm@kvack.org>; Wed, 3 Oct 2007 01:36:33 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l92FaY5f4149326
	for <linux-mm@kvack.org>; Wed, 3 Oct 2007 01:36:34 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l92FaY3s017498
	for <linux-mm@kvack.org>; Wed, 3 Oct 2007 01:36:34 +1000
Message-ID: <4702657B.9060501@linux.vnet.ibm.com>
Date: Tue, 02 Oct 2007 21:06:27 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [BUGFIX][RFC][PATCH][only -mm] FIX memory leak in memory cgroup
 vs. page migration [2/1] additional patch for migrate page/memory cgroup
References: <20071002183031.3352be6a.kamezawa.hiroyu@jp.fujitsu.com> <20071002183306.0c132ff4.kamezawa.hiroyu@jp.fujitsu.com> <20071002191217.61b4cf77.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071002191217.61b4cf77.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> The patch I sent needs following fix, sorry.
> Anyway, I'll repost good-version with reflected comments again.
> 
> Thanks,
>  -Kame

Just saw this now, I'll apply both the fixes, but it would be helpful
if you could post, one combined patch.

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
