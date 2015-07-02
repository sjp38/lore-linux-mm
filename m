Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 30AFA6B0274
	for <linux-mm@kvack.org>; Thu,  2 Jul 2015 09:25:15 -0400 (EDT)
Received: by igcur8 with SMTP id ur8so118473030igc.0
        for <linux-mm@kvack.org>; Thu, 02 Jul 2015 06:25:15 -0700 (PDT)
Received: from mail-ie0-x22c.google.com (mail-ie0-x22c.google.com. [2607:f8b0:4001:c03::22c])
        by mx.google.com with ESMTPS id d7si2296192igo.56.2015.07.02.06.25.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jul 2015 06:25:14 -0700 (PDT)
Received: by ieqy10 with SMTP id y10so56481525ieq.0
        for <linux-mm@kvack.org>; Thu, 02 Jul 2015 06:25:14 -0700 (PDT)
Message-ID: <55953BB7.70908@gmail.com>
Date: Thu, 02 Jul 2015 09:25:11 -0400
From: nick <xerofoify@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm:Make the function set_recommended_min_free_kbytes
 have a return type of void
References: <1435772715-9534-1-git-send-email-xerofoify@gmail.com> <20150702072302.GA12547@dhcp22.suse.cz>
In-Reply-To: <20150702072302.GA12547@dhcp22.suse.cz>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, ebru.akagunduz@gmail.com, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 2015-07-02 03:23 AM, Michal Hocko wrote:
> On Wed 01-07-15 13:45:15, Nicholas Krause wrote:
>> This makes the function set_recommended_min_free_kbytes have a
>> return type of void now due to this particular function never
>> needing to signal it's call if it fails due to this function
>> always completing successfully without issue.
> 
> The changelog is hard to read for me.
> "
> The function cannot possibly fail so it doesn't make much sense to have
> a return value. Make it void.
> "
> Would sound much easier to parse for me.
> 
> I doubt this would help the compiler to generate a better code but in
> general it is better to have void return type when there is no failure
> possible - which is the case here.
> 
>> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> 
> Acked-by: Michal Hocko <mhocko@suse.cz>
> 
>> ---
>>  mm/huge_memory.c | 3 +--
>>  1 file changed, 1 insertion(+), 2 deletions(-)
>>
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index c107094..914a72a 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -104,7 +104,7 @@ static struct khugepaged_scan khugepaged_scan = {
>>  };
>>  
>>  
>> -static int set_recommended_min_free_kbytes(void)
>> +static void set_recommended_min_free_kbytes(void)
>>  {
>>  	struct zone *zone;
>>  	int nr_zones = 0;
>> @@ -139,7 +139,6 @@ static int set_recommended_min_free_kbytes(void)
>>  		min_free_kbytes = recommended_min;
>>  	}
>>  	setup_per_zone_wmarks();
>> -	return 0;
>>  }
>>  
>>  static int start_stop_khugepaged(void)
>> -- 
>> 2.1.4
>>
> 
That was exactly my point with these patches readability not compiler improvements.
Otherwise I would have stated that in my commit messages and would argue readability
improvements are important too for the kernel.
Nick 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
