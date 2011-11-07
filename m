Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1D53E6B0069
	for <linux-mm@kvack.org>; Mon,  7 Nov 2011 17:22:43 -0500 (EST)
Message-ID: <4EB85A29.3010604@jp.fujitsu.com>
Date: Mon, 07 Nov 2011 14:22:33 -0800
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] oom: do not kill tasks with oom_score_adj OOM_SCORE_ADJ_MIN
References: <20111104143145.0F93B8B45E@mx2.suse.de> <alpine.DEB.2.00.1111071353140.27419@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1111071353140.27419@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com
Cc: mhocko@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, oleg@redhat.com, yinghan@google.com, akpm@linux-foundation.org

(11/7/2011 1:54 PM), David Rientjes wrote:
> On Fri, 4 Nov 2011, Michal Hocko wrote:
> 
>> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
>> index e916168..4883514 100644
>> --- a/mm/oom_kill.c
>> +++ b/mm/oom_kill.c
>> @@ -185,6 +185,9 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
>>  	if (!p)
>>  		return 0;
>>  
>> +	if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
>> +		return 0;
>> +
>>  	/*
>>  	 * The memory controller may have a limit of 0 bytes, so avoid a divide
>>  	 * by zero, if necessary.
> 
> This leaves p locked, you need to do task_unlock(p) first.
> 
> Once that's fixed, please add my
> 
> 	Acked-by: David Rientjes <rientjes@google.com>

Agreed.
	Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
