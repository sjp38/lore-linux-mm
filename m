Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l6AG1pOl324610
	for <linux-mm@kvack.org>; Wed, 11 Jul 2007 02:01:51 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.250.237])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l6AFgcX7034842
	for <linux-mm@kvack.org>; Wed, 11 Jul 2007 01:42:39 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6AFd60d003765
	for <linux-mm@kvack.org>; Wed, 11 Jul 2007 01:39:06 +1000
Message-ID: <4693A813.7090005@linux.vnet.ibm.com>
Date: Tue, 10 Jul 2007 21:08:59 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm PATCH 6/8] Memory controller add per container LRU and reclaim
 (v2)
References: <20070706052212.11677.26502.sendpatchset@balbir-laptop> <20070710084153.C07D91BF6B5@siro.lan>
In-Reply-To: <20070710084153.C07D91BF6B5@siro.lan>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: svaidy@linux.vnet.ibm.com, akpm@linux-foundation.org, xemul@openvz.org, a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ebiederm@xmission.com, containers@lists.osdl.org, menage@google.com
List-ID: <linux-mm.kvack.org>

YAMAMOTO Takashi wrote:
>> Add the meta_page to the per container LRU. The reclaim algorithm has been
>> modified to make the isolate_lru_pages() as a pluggable component. The
>> scan_control data structure now accepts the container on behalf of which
>> reclaims are carried out. try_to_free_pages() has been extended to become
>> container aware.
>>
>> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> it seems that the number of pages to scan (nr_active/nr_inactive
> in shrink_zone) is calculated from NR_ACTIVE and NR_INACTIVE of the zone,
> even in the case of per-container reclaim.  is it intended?
> 
> YAMAMOTO Takashi

Good catch again! We do that for now since the per zone LRU is a superset
of the container LRU. I see this as an important TODO item for us -- to
move to reclaim statistics based on per container nr_active and nr_inactive
(to be added).

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
