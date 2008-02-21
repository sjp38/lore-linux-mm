Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id m1LB7TFf005230
	for <linux-mm@kvack.org>; Thu, 21 Feb 2008 22:07:29 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1LBAI4w276904
	for <linux-mm@kvack.org>; Thu, 21 Feb 2008 22:10:18 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1LB6dv6003093
	for <linux-mm@kvack.org>; Thu, 21 Feb 2008 22:06:40 +1100
Message-ID: <47BD5A31.9070401@linux.vnet.ibm.com>
Date: Thu, 21 Feb 2008 16:32:09 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] the proposal of improve page reclaim by throttle
References: <20080219134715.7E90.KOSAKI.MOTOHIRO@jp.fujitsu.com> <47BD48F3.3040903@linux.vnet.ibm.com> <2f11576a0802210301sb162ac9u6cf4ba4d5cb179b4@mail.gmail.com>
In-Reply-To: <2f11576a0802210301sb162ac9u6cf4ba4d5cb179b4@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
> Hi balbir-san
> 
>>  It's good to keep the main reclaim code and the memory controller reclaim in
>>  sync, so this is a nice effort.
> 
> thank you.
> I will repost next version (fixed nick's opinion) while a few days.
> 
>>  > @@ -1456,7 +1501,7 @@ unsigned long try_to_free_mem_cgroup_pag
>>  >       int target_zone = gfp_zone(GFP_HIGHUSER_MOVABLE);
>>  >
>>  >       zones = NODE_DATA(numa_node_id())->node_zonelists[target_zone].zones;
>>  > -     if (do_try_to_free_pages(zones, sc.gfp_mask, &sc))
>>  > +     if (try_to_free_pages_throttled(zones, 0, sc.gfp_mask, &sc))
>>  >               return 1;
>>  >       return 0;
>>  >  }
>>
>>  try_to_free_pages_throttled checks for zone_watermark_ok(), that will not work
>>  in the case that we are reclaiming from a cgroup which over it's limit. We need
>>  a different check, to see if the mem_cgroup is still over it's limit or not.
> 
> That makes sense.
> 
> unfortunately, I don't know mem-cgroup so much.
> What do i use function, instead?

One option could be that once the memory controller has this feature, we'll need
no changes in try_to_free_mem_cgroup_pages.

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
