Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id B64C46B0038
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 09:49:56 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id hb5so116185717wjc.2
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 06:49:56 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i2si77961649wma.140.2017.01.04.06.49.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 Jan 2017 06:49:55 -0800 (PST)
Subject: Re: [PATCH 3/3] oom, trace: add compaction retry tracepoint
References: <20161220130135.15719-1-mhocko@kernel.org>
 <20161220130135.15719-4-mhocko@kernel.org>
 <6f3a808d-7799-80f5-9c00-4fb996dc31fa@suse.cz>
 <20170104105629.GF25453@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d8854f76-a421-4e9e-08ef-abd2e5c15007@suse.cz>
Date: Wed, 4 Jan 2017 15:49:54 +0100
MIME-Version: 1.0
In-Reply-To: <20170104105629.GF25453@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 01/04/2017 11:56 AM, Michal Hocko wrote:
> On Wed 04-01-17 11:47:56, Vlastimil Babka wrote:
>> On 12/20/2016 02:01 PM, Michal Hocko wrote:
>>> From: Michal Hocko <mhocko@suse.com>
>>
>> --------8<--------
>> From: Vlastimil Babka <vbabka@suse.cz>
>> Date: Wed, 4 Jan 2017 11:44:09 +0100
>> Subject: [PATCH] oom, trace: add compaction retry tracepoint-fix
>>
>> Let's print the compaction priorities lower-case and without
>> prefix for consistency.
>>
>> Also indent fix in compact_result_to_feedback().
>>
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> 
> I would just worry that c&p constant name is easier to work with when
> vim -t $PRIO or git grep $PRIO. But if the lowercase and shorter sounds
> better to you then no objections from me.

Yeah, valid point, but since we didn't do that until now, let's stay
consistent.

>> ---
>>  include/trace/events/mmflags.h | 8 ++++----
>>  1 file changed, 4 insertions(+), 4 deletions(-)
>>
>> diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
>> index aa4caa6914a9..e4c3a0febcce 100644
>> --- a/include/trace/events/mmflags.h
>> +++ b/include/trace/events/mmflags.h
>> @@ -195,7 +195,7 @@ IF_HAVE_VM_SOFTDIRTY(VM_SOFTDIRTY,	"softdirty"	)		\
>>  
>>  #define compact_result_to_feedback(result)	\
>>  ({						\
>> - 	enum compact_result __result = result;	\
>> +	enum compact_result __result = result;	\
>>  	(compaction_failed(__result)) ? COMPACTION_FAILED : \
>>  		(compaction_withdrawn(__result)) ? COMPACTION_WITHDRAWN : COMPACTION_PROGRESS; \
>>  })
>> @@ -206,9 +206,9 @@ IF_HAVE_VM_SOFTDIRTY(VM_SOFTDIRTY,	"softdirty"	)		\
>>  	EMe(COMPACTION_PROGRESS,	"progress")
>>  
>>  #define COMPACTION_PRIORITY						\
>> -	EM(COMPACT_PRIO_SYNC_FULL,	"COMPACT_PRIO_SYNC_FULL")	\
>> -	EM(COMPACT_PRIO_SYNC_LIGHT,	"COMPACT_PRIO_SYNC_LIGHT")	\
>> -	EMe(COMPACT_PRIO_ASYNC,		"COMPACT_PRIO_ASYNC")
>> +	EM(COMPACT_PRIO_SYNC_FULL,	"sync_full")	\
>> +	EM(COMPACT_PRIO_SYNC_LIGHT,	"sync_light")	\
>> +	EMe(COMPACT_PRIO_ASYNC,		"async")
>>  #else
>>  #define COMPACTION_STATUS
>>  #define COMPACTION_PRIORITY
>> -- 
>> 2.11.0
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
