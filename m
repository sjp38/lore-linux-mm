Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B2B596B005D
	for <linux-mm@kvack.org>; Mon, 20 Jul 2009 08:14:51 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n6KCCaEN012032
	for <linux-mm@kvack.org>; Mon, 20 Jul 2009 06:12:36 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n6KCEqPj193772
	for <linux-mm@kvack.org>; Mon, 20 Jul 2009 06:14:52 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n6KCEpM4018948
	for <linux-mm@kvack.org>; Mon, 20 Jul 2009 06:14:51 -0600
Date: Mon, 20 Jul 2009 17:44:50 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 10/10] ksm: change ksm nice level to be 5
Message-ID: <20090720121450.GG24157@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1247851850-4298-4-git-send-email-ieidus@redhat.com> <1247851850-4298-5-git-send-email-ieidus@redhat.com> <1247851850-4298-6-git-send-email-ieidus@redhat.com> <1247851850-4298-7-git-send-email-ieidus@redhat.com> <1247851850-4298-8-git-send-email-ieidus@redhat.com> <1247851850-4298-9-git-send-email-ieidus@redhat.com> <1247851850-4298-10-git-send-email-ieidus@redhat.com> <1247851850-4298-11-git-send-email-ieidus@redhat.com> <20090720045037.GA24157@balbir.in.ibm.com> <4A645974.3020801@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <4A645974.3020801@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: akpm@linux-foundation.org, hugh.dickins@tiscali.co.uk, aarcange@redhat.com, chrisw@redhat.com, avi@redhat.com, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

* Izik Eidus <ieidus@redhat.com> [2009-07-20 14:48:04]:

> Balbir Singh wrote:
>> * Izik Eidus <ieidus@redhat.com> [2009-07-17 20:30:50]:
>>
>>   
>>> From: Izik Eidus <ieidus@redhat.com>
>>>
>>> ksm should try not to disturb other tasks as much as possible.
>>>
>>> Signed-off-by: Izik Eidus <ieidus@redhat.com>
>>> ---
>>>  mm/ksm.c |    2 +-
>>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>>
>>> diff --git a/mm/ksm.c b/mm/ksm.c
>>> index 75d7802..4afe345 100644
>>> --- a/mm/ksm.c
>>> +++ b/mm/ksm.c
>>> @@ -1270,7 +1270,7 @@ static void ksm_do_scan(unsigned int scan_npages)
>>>
>>>  static int ksm_scan_thread(void *nothing)
>>>  {
>>> -	set_user_nice(current, 0);
>>> +	set_user_nice(current, 5);
>>>     
>>
>> Is the 5 arbitrary? Why not +19? What is the intention of this change
>> - to run when no other task is ready to run?
>>   
>
> Hey Balbir,
>
> I thought about giving it the lowest priority of nice before I did this  
> patch, but then I came into understanding that it isn't right,
> Although ksm should not distrub other tasks while they are running, it  
> does need to run while they are running,
> most of the use cases for ksm is to find identical pages in real time  
> while they are changing in the application, so giving it the lowest  
> priority doesn't seems right to me,
>
> But my understanding of how the nice prioritys are working is just my  
> intuition, so if you know better and think that for the use case i  
> described above other nice priority is better fit, tell me and I wont  
> have any problem to change.
>
>


I was just checking to see why 5? May be it might be a good idea to
document or at-least have rules on what priorities kernel threads can
take? 

>>   
>>>  	while (!kthread_should_stop()) {
>>>  		if (ksm_run & KSM_RUN_MERGE) {
>>>     
>>
>>   
>

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
