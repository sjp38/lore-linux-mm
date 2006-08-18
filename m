Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e36.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k7I3XIhl029525
	for <linux-mm@kvack.org>; Thu, 17 Aug 2006 23:33:18 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7I3XH1b246886
	for <linux-mm@kvack.org>; Thu, 17 Aug 2006 21:33:17 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7I3XHDG029123
	for <linux-mm@kvack.org>; Thu, 17 Aug 2006 21:33:17 -0600
Message-ID: <44E534F1.903@in.ibm.com>
Date: Fri, 18 Aug 2006 09:03:05 +0530
From: Balbir Singh <balbir@in.ibm.com>
Reply-To: balbir@in.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] "challenged" memory controller
References: <20060815192047.EE4A0960@localhost.localdomain>	 <20060815150721.21ff961e.pj@sgi.com>  <44E447E7.8070502@in.ibm.com> <1155826045.9274.44.camel@localhost.localdomain>
In-Reply-To: <1155826045.9274.44.camel@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Paul Jackson <pj@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> On Thu, 2006-08-17 at 16:11 +0530, Balbir Singh wrote:
>> Would it be possible to protect task->cpuset using rcu_read_lock() for read 
>> references as cpuset_update_task_memory_state() does (and use the generations 
>> trick to see if a task changed cpusets)? I guess the cost paid is an additional 
>> field in the page structure to add generations. 
> 
> cpusets isn't going to be used long-term here, so we don't really have
> to worry about it.
> 
> -- Dave
> 

Yes, good point. Thanks for keeping me on course.

-- 

	Balbir Singh,
	Linux Technology Center,
	IBM Software Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
