Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D9E936B004A
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 23:53:12 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e38.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o9M3jAOh000834
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 21:45:10 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id o9M3r8C1222572
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 21:53:08 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o9M3r8GL019365
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 21:53:08 -0600
Date: Fri, 22 Oct 2010 09:23:03 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH V3] nommu: add anonymous page memcg accounting
Message-ID: <20101022035302.GA15844@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1287664088-4483-1-git-send-email-steve@digidescorp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1287664088-4483-1-git-send-email-steve@digidescorp.com>
Sender: owner-linux-mm@kvack.org
To: "Steven J. Magnani" <steve@digidescorp.com>
Cc: linux-mm@kvack.org, dhowells@redhat.com, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

* Steven J. Magnani <steve@digidescorp.com> [2010-10-21 07:28:08]:

> Add the necessary calls to track VM anonymous page usage (only).
> 
> V3 changes:
> * Use vma->vm_mm instead of current->mm when charging pages, for clarity
> * Document that reclaim is not possible with only anonymous page accounting
>   so the OOM-killer is invoked when a limit is exceeded
> * Add TODO to implement file cache (reclaim) support or optimize away
>   page_cgroup->lru
> 
> V2 changes:
> * Added update of memory cgroup documentation
> * Clarify use of 'file' to distinguish anonymous mappings
> 
> Signed-off-by: Steven J. Magnani <steve@digidescorp.com>

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

BTW, I have no way of testing this, we need to rely on the NOMMU
community to test this.
 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
