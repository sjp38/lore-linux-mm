Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C44708D0039
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 19:52:13 -0500 (EST)
Received: by fxm5 with SMTP id 5so3586077fxm.14
        for <linux-mm@kvack.org>; Fri, 04 Mar 2011 16:52:10 -0800 (PST)
Message-ID: <4D718933.1050106@gmail.com>
Date: Sat, 05 Mar 2011 03:52:03 +0300
From: "avagin@gmail.com" <avagin@gmail.com>
Reply-To: avagin@gmail.com
MIME-Version: 1.0
Subject: Re: [PATCH rh6] mm: skip zombie in OOM-killer
References: <1299274256-2122-1-git-send-email-avagin@openvz.org> <alpine.DEB.2.00.1103041541040.7795@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1103041541040.7795@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrey Vagin <avagin@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 03/05/2011 02:41 AM, David Rientjes wrote:
> On Sat, 5 Mar 2011, Andrey Vagin wrote:
>
>> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
>> index 7dcca55..2fc554e 100644
>> --- a/mm/oom_kill.c
>> +++ b/mm/oom_kill.c
>> @@ -311,7 +311,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
>>   		 * blocked waiting for another task which itself is waiting
>>   		 * for memory. Is there a better alternative?
>>   		 */
>> -		if (test_tsk_thread_flag(p, TIF_MEMDIE))
>> +		if (test_tsk_thread_flag(p, TIF_MEMDIE)&&  p->mm)
>>   			return ERR_PTR(-1UL);
>>
>>   		/*
>
> I think it would be better to just do
>
> 	if (!p->mm)
> 		continue;
>
> after the check for oom_unkillable_task() because everything that follows
> this really depends on p->mm being non-NULL to actually do anything
> useful.
Yes. You are right. Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
