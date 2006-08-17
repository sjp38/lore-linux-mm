Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k7HElTIT005577
	for <linux-mm@kvack.org>; Thu, 17 Aug 2006 10:47:29 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7HElTFj221200
	for <linux-mm@kvack.org>; Thu, 17 Aug 2006 10:47:29 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7HElTXi019786
	for <linux-mm@kvack.org>; Thu, 17 Aug 2006 10:47:29 -0400
Subject: Re: [RFC][PATCH] "challenged" memory controller
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <44E447E7.8070502@in.ibm.com>
References: <20060815192047.EE4A0960@localhost.localdomain>
	 <20060815150721.21ff961e.pj@sgi.com>  <44E447E7.8070502@in.ibm.com>
Content-Type: text/plain
Date: Thu, 17 Aug 2006 07:47:25 -0700
Message-Id: <1155826045.9274.44.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@in.ibm.com
Cc: Paul Jackson <pj@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2006-08-17 at 16:11 +0530, Balbir Singh wrote:
> Would it be possible to protect task->cpuset using rcu_read_lock() for read 
> references as cpuset_update_task_memory_state() does (and use the generations 
> trick to see if a task changed cpusets)? I guess the cost paid is an additional 
> field in the page structure to add generations. 

cpusets isn't going to be used long-term here, so we don't really have
to worry about it.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
