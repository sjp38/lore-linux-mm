Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 94E716B004A
	for <linux-mm@kvack.org>; Mon,  4 Oct 2010 13:35:24 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp09.au.ibm.com (8.14.4/8.13.1) with ESMTP id o94HZIWq028516
	for <linux-mm@kvack.org>; Tue, 5 Oct 2010 04:35:18 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o94HZFkJ2240550
	for <linux-mm@kvack.org>; Tue, 5 Oct 2010 04:35:18 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o94HZEHS026786
	for <linux-mm@kvack.org>; Tue, 5 Oct 2010 04:35:14 +1100
Message-ID: <4CAA104C.3000708@linux.vnet.ibm.com>
Date: Mon, 04 Oct 2010 23:05:08 +0530
From: Ciju Rajan K <ciju@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 03/10] memcg: create extensible page stat update routines
References: <1286175485-30643-1-git-send-email-gthelen@google.com> <1286175485-30643-4-git-send-email-gthelen@google.com> <4CA9DB3E.6020106@linux.vnet.ibm.com> <xr93y6ae2cb1.fsf@ninji.mtv.corp.google.com>
In-Reply-To: <xr93y6ae2cb1.fsf@ninji.mtv.corp.google.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Greg Thelen wrote:
> Ciju Rajan K <ciju@linux.vnet.ibm.com> writes:
>
>   
>> Greg Thelen wrote:
>>     
>>> Replace usage of the mem_cgroup_update_file_mapped() memcg
>>> statistic update routine with two new routines:
>>> * mem_cgroup_inc_page_stat()
>>> * mem_cgroup_dec_page_stat()
>>>
>>> As before, only the file_mapped statistic is managed.  However,
>>> these more general interfaces allow for new statistics to be
>>> more easily added.  New statistics are added with memcg dirty
>>> page accounting.
>>>
>>>
>>>
>>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>>> index 512cb12..f4259f4 100644
>>> --- a/mm/memcontrol.c
>>> +++ b/mm/memcontrol.c
>>> @@ -1592,7 +1592,9 @@ bool mem_cgroup_handle_oom(struct mem_cgroup *mem, gfp_t mask)
>>>   * possibility of race condition. If there is, we take a lock.
>>>   */
>>>
>>>   -static void mem_cgroup_update_file_stat(struct page *page, int idx, int
>>> val)
>>>   
>>>       
>> Not seeing this function in mmotm 28/09. So not able to apply this patch.
>> Am I missing anything?
>>     
>
> How are you getting mmotm?
>
> I see the mem_cgroup_update_file_stat() routine added in mmotm
> (stamp-2010-09-28-16-13) using patch file:
>   http://userweb.kernel.org/~akpm/mmotm/broken-out/memcg-generic-filestat-update-interface.patch
>   
Sorry for the noise Greg. It was a mistake at my end. Corrected now.
Thanks!
>   Author: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>   Date:   Tue Sep 28 21:48:19 2010 -0700
>   
>       This patch extracts the core logic from mem_cgroup_update_file_mapped() as
>       mem_cgroup_update_file_stat() and adds a wrapper.
>   
>       As a planned future update, memory cgroup has to count dirty pages to
>       implement dirty_ratio/limit.  And more, the number of dirty pages is
>       required to kick flusher thread to start writeback.  (Now, no kick.)
>   
>       This patch is preparation for it and makes other statistics implementation
>       clearer.  Just a clean up.
>   
>       Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>       Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
>       Reviewed-by: Greg Thelen <gthelen@google.com>
>       Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
>       Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>
> If you are using the zen mmotm repository,
> git://zen-kernel.org/kernel/mmotm.git, the commit id of
> memcg-generic-filestat-update-interface.patch is
> 616960dc0cb0172a5e5adc9e2b83e668e1255b50.
>
>   
>>> +void mem_cgroup_update_page_stat(struct page *page,
>>> +				 enum mem_cgroup_write_page_stat_item idx,
>>> +				 int val)
>>>  {
>>>  	struct mem_cgroup *mem;
>>>
>>>   
>>>       

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
