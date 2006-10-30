Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.8/8.13.5) with ESMTP id k9UIILYm256216
	for <linux-mm@kvack.org>; Tue, 31 Oct 2006 05:18:26 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by sd0208e0.au.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k9UIBIJ0194350
	for <linux-mm@kvack.org>; Tue, 31 Oct 2006 05:11:28 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k9UI3MCe004223
	for <linux-mm@kvack.org>; Tue, 31 Oct 2006 05:03:22 +1100
Message-ID: <45463F70.1010303@in.ibm.com>
Date: Mon, 30 Oct 2006 23:37:44 +0530
From: Balbir Singh <balbir@in.ibm.com>
Reply-To: balbir@in.ibm.com
MIME-Version: 1.0
Subject: Re: [ckrm-tech] RFC: Memory Controller
References: <20061030103356.GA16833@in.ibm.com> <4545D51A.1060808@in.ibm.com> <4546212B.4010603@openvz.org> <454638D2.7050306@in.ibm.com>
In-Reply-To: <454638D2.7050306@in.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@in.ibm.com
Cc: Pavel Emelianov <xemul@openvz.org>, vatsa@in.ibm.com, dev@openvz.org, sekharan@us.ibm.com, ckrm-tech@lists.sourceforge.net, haveblue@us.ibm.com, linux-kernel@vger.kernel.org, pj@sgi.com, matthltc@us.ibm.com, dipankar@in.ibm.com, rohitseth@google.com, menage@google.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
[snip]

>
>> I see that everyone agree that we want to see three resources:
>>   1. kernel memory
>>   2. unreclaimable memory
>>   3. reclaimable memory
>> if this is right then let's save it somewhere
>> (e.g. http://wiki.openvz.org/Containers/UBC_discussion)
>> and go on discussing the next question - interface.
> 
> I understand that kernel memory accounting is the first priority for
> containers, but accounting kernel memory requires too many changes
> to the VM core, hence I was hesitant to put it up as first priority.
> 
> But in general I agree, these are the three important resources for
> accounting and control

I missed out to mention, I hope you were including the page cache in
your definition of reclaimable memory.

> 
> [snip]
> 


-- 

	Balbir Singh,
	Linux Technology Center,
	IBM Software Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
