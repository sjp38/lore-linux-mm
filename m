Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 39B906B0167
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 04:31:19 -0400 (EDT)
Message-ID: <4FE972B2.1020509@parallels.com>
Date: Tue, 26 Jun 2012 12:28:34 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 03/11] memcg: change defines to an enum
References: <1340633728-12785-1-git-send-email-glommer@parallels.com> <1340633728-12785-4-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1206252110470.26640@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1206252110470.26640@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>

On 06/26/2012 08:11 AM, David Rientjes wrote:
> On Mon, 25 Jun 2012, Glauber Costa wrote:
>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 8e601e8..9352d40 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -387,9 +387,12 @@ enum charge_type {
>>   };
>>
>>   /* for encoding cft->private value on file */
>> -#define _MEM			(0)
>> -#define _MEMSWAP		(1)
>> -#define _OOM_TYPE		(2)
>> +enum res_type {
>> +	_MEM,
>> +	_MEMSWAP,
>> +	_OOM_TYPE,
>> +};
>> +
>>   #define MEMFILE_PRIVATE(x, val)	((x) << 16 | (val))
>>   #define MEMFILE_TYPE(val)	((val) >> 16 & 0xffff)
>>   #define MEMFILE_ATTR(val)	((val) & 0xffff)
>
> Shouldn't everything that does MEMFILE_TYPE() now be using type
> enum res_type rather than int?
>
If you mean the following three fields, no, since they are masks and 
operations.

If you mean something else, what do you mean ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
