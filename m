Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 2F65A6B0039
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 03:36:07 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id rp16so6894365pbb.37
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 00:36:06 -0700 (PDT)
Received: from e28smtp05.in.ibm.com (e28smtp05.in.ibm.com. [122.248.162.5])
        by mx.google.com with ESMTPS id fl5si24958004pbb.220.2014.06.24.00.36.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 24 Jun 2014 00:36:06 -0700 (PDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <lilei@linux.vnet.ibm.com>;
	Tue, 24 Jun 2014 13:06:02 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id E49EFE005B
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 13:07:11 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s5O7aFor63701026
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 13:06:16 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s5O7ZwAY030347
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 13:05:58 +0530
Message-ID: <53A92A5B.4070403@linux.vnet.ibm.com>
Date: Tue, 24 Jun 2014 15:35:55 +0800
From: Lei Li <lilei@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Documentation: Update remove_from_page_cache with delete_from_page_cache
References: <1403514679-24632-1-git-send-email-lilei@linux.vnet.ibm.com> <20140623092305.GF9743@dhcp22.suse.cz>
In-Reply-To: <20140623092305.GF9743@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: hannes@cmpxchg.org, tj@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org


On 06/23/2014 05:23 PM, Michal Hocko wrote:
> On Mon 23-06-14 17:11:19, Lei Li wrote:
>> remove_from_page_cache has been renamed to delete_from_page_cache
>> since Commit 702cfbf9 ("mm: goodbye remove_from_page_cache()"), adapt
>> to it in Memcg documentation.
>>
>> Signed-off-by: Lei Li <lilei@linux.vnet.ibm.com>
> This conflicts with the current mmotm tree because of Johannes' {un}charge rewrite.
> Anyway the comment is not up-to-date anyway. __delete_from_page_cache is
> called from more places and I do not see quite a good reason why to keep
> this in the documentation.
> I would just remove this note as it doesn't serve any useful purpose.

Thanks for your reply.
Just take a quick look at Johannes' patch of rewriting uncharge API. I'll
resend a patch with the note removed.


Thanks,

Lei

>
>> ---
>>   Documentation/cgroups/memcg_test.txt | 4 ++--
>>   1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/Documentation/cgroups/memcg_test.txt b/Documentation/cgroups/memcg_test.txt
>> index 80ac454..b2d6ccc 100644
>> --- a/Documentation/cgroups/memcg_test.txt
>> +++ b/Documentation/cgroups/memcg_test.txt
>> @@ -171,10 +171,10 @@ Under below explanation, we assume CONFIG_MEM_RES_CTRL_SWAP=y.
>>   	- add_to_page_cache_locked().
>>   
>>   	uncharged at
>> -	- __remove_from_page_cache().
>> +	- __delete_from_page_cache().
>>   
>>   	The logic is very clear. (About migration, see below)
>> -	Note: __remove_from_page_cache() is called by remove_from_page_cache()
>> +	Note: __delete_from_page_cache() is called by delete_from_page_cache()
>>   	and __remove_mapping().
>>   
>>   6. Shmem(tmpfs) Page Cache
>> -- 
>> 1.8.5.3
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
