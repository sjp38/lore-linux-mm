Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m07EAJIV013101
	for <linux-mm@kvack.org>; Mon, 7 Jan 2008 09:10:19 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m07EAJr6163986
	for <linux-mm@kvack.org>; Mon, 7 Jan 2008 07:10:19 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m07EAIDp012566
	for <linux-mm@kvack.org>; Mon, 7 Jan 2008 07:10:19 -0700
Message-ID: <478232BB.3040406@linux.vnet.ibm.com>
Date: Mon, 07 Jan 2008 19:40:03 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [patch 07/19] split anon & file LRUs for memcontrol code
References: <20080102224144.885671949@redhat.com> <20080102224154.309980291@redhat.com> <20080107190455.22412330.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080107190455.22412330.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "riel@redhat.com" <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Wed, 02 Jan 2008 17:41:51 -0500
> linux-kernel@vger.kernel.org wrote:
> 
>> Index: linux-2.6.24-rc6-mm1/mm/vmscan.c
>> ===================================================================
>> --- linux-2.6.24-rc6-mm1.orig/mm/vmscan.c	2008-01-02 15:55:55.000000000 -0500
>> +++ linux-2.6.24-rc6-mm1/mm/vmscan.c	2008-01-02 15:56:00.000000000 -0500
>> @@ -1230,13 +1230,13 @@ static unsigned long shrink_zone(int pri
>>  
>>  	get_scan_ratio(zone, sc, percent);
>>  
> 
> I'm happy if this calclation can be following later.
> ==
> if (scan_global_lru(sc)) {
> 	get_scan_ratio(zone, sc, percent);
> } else {
> 	get_scan_ratio_cgroup(sc->cgroup, sc, percent);
> }
> ==
> To do this, 
> mem_cgroup needs to have recent_rotated_file and recent_rolated_anon ?

Yes, that makes sense.

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
