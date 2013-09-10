Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id C54896B0031
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 20:57:38 -0400 (EDT)
Message-ID: <522E6E5F.7050006@huawei.com>
Date: Tue, 10 Sep 2013 08:57:03 +0800
From: Qiang Huang <h.huangqiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm, memcg: add a helper function to check may oom condition
References: <522D2FE5.3080606@huawei.com> <alpine.DEB.2.02.1309091317570.16291@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1309091317570.16291@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, hannes@cmpxchg.org, Li Zefan <lizefan@huawei.com>, Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 2013/9/10 4:22, David Rientjes wrote:
> On Mon, 9 Sep 2013, Qiang Huang wrote:
> 
>> diff --git a/include/linux/oom.h b/include/linux/oom.h
>> index da60007..d061c63 100644
>> --- a/include/linux/oom.h
>> +++ b/include/linux/oom.h
>> @@ -82,6 +82,11 @@ static inline void oom_killer_enable(void)
>>  	oom_killer_disabled = false;
>>  }
>>
>> +static inline bool may_oom(gfp_t gfp_mask)
> 
> Makes sense, but I think the name should be more specific to gfp flags to 
> make it clear what it's using to determine eligibility, maybe oom_gfp_allowed()? 
> We usually prefix oom killer functions with "oom".

Yes, oom_gfp_allowed() seems better, I'll send a second version,
thanks for you advice, David.

> 
> Nice taste.
> 
>> +{
>> +	return (gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY);
>> +}
>> +
>>  extern struct task_struct *find_lock_task_mm(struct task_struct *p);
>>
>>  /* sysctls */
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
