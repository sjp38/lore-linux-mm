Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7F4146B006A
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 04:37:19 -0400 (EDT)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp09.in.ibm.com (8.14.4/8.13.1) with ESMTP id o958FORl006075
	for <linux-mm@kvack.org>; Tue, 5 Oct 2010 13:45:24 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o958bBci3698772
	for <linux-mm@kvack.org>; Tue, 5 Oct 2010 14:07:11 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o958bBC9015982
	for <linux-mm@kvack.org>; Tue, 5 Oct 2010 14:07:11 +0530
Message-ID: <4CAAE3B4.8000904@linux.vnet.ibm.com>
Date: Tue, 05 Oct 2010 14:07:08 +0530
From: Ciju Rajan K <ciju@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/10] memcg: per cgroup dirty page accounting
References: <1286175485-30643-1-git-send-email-gthelen@google.com> <20101005045023.GS7896@balbir.in.ibm.com> <xr93pqvpxk5z.fsf@ninji.mtv.corp.google.com>
In-Reply-To: <xr93pqvpxk5z.fsf@ninji.mtv.corp.google.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: balbir@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Greg Thelen wrote:
> Balbir Singh <balbir@linux.vnet.ibm.com> writes:
>   
>> * Greg Thelen <gthelen@google.com> [2010-10-03 23:57:55]:
>>
>>     
>>> This patch set provides the ability for each cgroup to have independent dirty
>>> page limits.
>>>
>>> Limiting dirty memory is like fixing the max amount of dirty (hard to reclaim)
>>> page cache used by a cgroup.  So, in case of multiple cgroup writers, they will
>>> not be able to consume more than their designated share of dirty pages and will
>>> be forced to perform write-out if they cross that limit.
>>>
>>> These patches were developed and tested on mmotm 2010-09-28-16-13.  The patches
>>> are based on a series proposed by Andrea Righi in Mar 2010.
>>>       
>> Hi, Greg,
>>
>> I see a problem with "    memcg: add dirty page accounting infrastructure".
>>
>> The reject is
>>
>>  enum mem_cgroup_write_page_stat_item {
>>         MEMCG_NR_FILE_MAPPED, /* # of pages charged as file rss */
>> +       MEMCG_NR_FILE_DIRTY, /* # of dirty pages in page cache */
>> +       MEMCG_NR_FILE_WRITEBACK, /* # of pages under writeback */
>> +       MEMCG_NR_FILE_UNSTABLE_NFS, /* # of NFS unstable pages */
>>  };
>>
>> I don't see mem_cgroup_write_page_stat_item in memcontrol.h. Is this
>> based on top of Kame's cleanup.
>>
>> I am working off of mmotm 28 sept 2010 16:13.
>>     
>
> Balbir,
>
> All of the 10 memcg dirty limits patches should apply directly to mmotm
> 28 sept 2010 16:13 without any other patches.  Any of Kame's cleanup
> patches that are not in mmotm are not needed by this memcg dirty limit
> series.
>
> The patch you refer to, "[PATCH 05/10] memcg: add dirty page accounting
> infrastructure" depends on a change from an earlier patch in the series.
> Specifically, "[PATCH 03/10] memcg: create extensible page stat update
> routines" contains the addition of mem_cgroup_write_page_stat_item:
>
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -25,6 +25,11 @@ struct page_cgroup;
>  struct page;
>  struct mm_struct;
>
> +/* Stats that can be updated by kernel. */
> +enum mem_cgroup_write_page_stat_item {
> +     MEMCG_NR_FILE_MAPPED, /* # of pages charged as file rss */
> +};
> +
>
> Do you have trouble applying patch 5 after applying patches 1-4?
>   
I could apply all the patches cleanly on mmotm 28/09/2010. Kernel build 
also went through.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
