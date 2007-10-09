Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id l99AmfsM011141
	for <linux-mm@kvack.org>; Tue, 9 Oct 2007 20:48:41 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l99Amg8a4001944
	for <linux-mm@kvack.org>; Tue, 9 Oct 2007 20:48:42 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l99AmQA5011756
	for <linux-mm@kvack.org>; Tue, 9 Oct 2007 20:48:26 +1000
Message-ID: <470B5C68.2070800@linux.vnet.ibm.com>
Date: Tue, 09 Oct 2007 16:18:08 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH][for -mm] Fix and Enhancements for memory cgroup [2/6]
 fix err handling in charging
References: <20071009184620.8b14cbc6.kamezawa.hiroyu@jp.fujitsu.com> <20071009185018.4d279d07.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071009185018.4d279d07.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> This unlock_page_cgroup() is unnecessary.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> 
>  mm/memcontrol.c |    2 --
>  1 file changed, 2 deletions(-)
> 
> Index: linux-2.6.23-rc8-mm2/mm/memcontrol.c
> ===================================================================
> --- linux-2.6.23-rc8-mm2.orig/mm/memcontrol.c
> +++ linux-2.6.23-rc8-mm2/mm/memcontrol.c
> @@ -381,9 +381,7 @@ done:
>  	return 0;
>  free_pc:
>  	kfree(pc);
> -	return -ENOMEM;
>  err:
> -	unlock_page_cgroup(page);
>  	return -ENOMEM;
>  }
> 
> 

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
