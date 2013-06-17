Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 2BBA66B0033
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 05:50:48 -0400 (EDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 17 Jun 2013 19:48:01 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 8B7612BB0054
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 19:50:39 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5H9oUSX5570908
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 19:50:30 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5H9ocdI030329
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 19:50:38 +1000
Date: Mon, 17 Jun 2013 17:50:36 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 4/7] mm/page_alloc: fix blank in show_free_areas
Message-ID: <20130617095036.GB21564@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1371345290-19588-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1371345290-19588-4-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130617081012.GA19194@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130617081012.GA19194@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Andrew Shewmaker <agshew@gmail.com>, Jiri Kosina <jkosina@suse.cz>, Namjae Jeon <linkinjeon@gmail.com>, Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jun 17, 2013 at 10:10:12AM +0200, Michal Hocko wrote:
>On Sun 16-06-13 09:14:47, Wanpeng Li wrote:
>> There is a blank in show_free_areas which lead to dump messages aren't
>> aligned. This patch remove blank.
>> 
>> Before patch:
>> 
>> [155219.720141] active_anon:50675 inactive_anon:35273 isolated_anon:0
>> [155219.720141]  active_file:215421 inactive_file:344268 isolated_file:0
>> [155219.720141]  unevictable:0 dirty:35 writeback:0 unstable:0
>> [155219.720141]  free:1334870 slab_reclaimable:28833 slab_unreclaimable:5115
>> [155219.720141]  mapped:25233 shmem:35511 pagetables:1705 bounce:0
>> [155219.720141]  free_cma:0
>> 
>> After patch:
>> 
>> [   73.913889] active_anon:39578 inactive_anon:32082 isolated_anon:0
>> [   73.913889] active_file:14621 inactive_file:57993 isolated_file:0
>> [   73.913889] unevictable:0dirty:263 writeback:0 unstable:0
>> [   73.913889] free:1865614 slab_reclaimable:3264 slab_unreclaimable:4566
>> [   73.913889] mapped:21192 shmem:32327 pagetables:1572 bounce:0
>> [   73.913889] free_cma:0
>
>Not that I would care much but this format is here for ages. An
>additional space was kind of nice to visually separate this part from
>the per-zone data.
>
>Is there any special reason for this change?
>

No special reason, I'm ok if you prefer the old format. ;-)

>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>> ---
>>  mm/page_alloc.c | 12 ++++++------
>>  1 file changed, 6 insertions(+), 6 deletions(-)
>> 
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 18102e1..e6e881a 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -3004,12 +3004,12 @@ void show_free_areas(unsigned int filter)
>>  	}
>>  
>>  	printk("active_anon:%lu inactive_anon:%lu isolated_anon:%lu\n"
>> -		" active_file:%lu inactive_file:%lu isolated_file:%lu\n"
>> -		" unevictable:%lu"
>> -		" dirty:%lu writeback:%lu unstable:%lu\n"
>> -		" free:%lu slab_reclaimable:%lu slab_unreclaimable:%lu\n"
>> -		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n"
>> -		" free_cma:%lu\n",
>> +		"active_file:%lu inactive_file:%lu isolated_file:%lu\n"
>> +		"unevictable:%lu"
>> +		"dirty:%lu writeback:%lu unstable:%lu\n"
>
>There is a space missing between unevictable and dirty.

Oh, I miss that. Thanks for pointing out. ;-)

Regards,
Wanpeng Li 

>
>> +		"free:%lu slab_reclaimable:%lu slab_unreclaimable:%lu\n"
>> +		"mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n"
>> +		"free_cma:%lu\n",
>>  		global_page_state(NR_ACTIVE_ANON),
>>  		global_page_state(NR_INACTIVE_ANON),
>>  		global_page_state(NR_ISOLATED_ANON),
>
>-- 
>Michal Hocko
>SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
