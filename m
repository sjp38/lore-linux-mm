Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id l8PHIkZU011516
	for <linux-mm@kvack.org>; Wed, 26 Sep 2007 03:18:46 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8PHIiaM4890672
	for <linux-mm@kvack.org>; Wed, 26 Sep 2007 03:18:44 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8PHHEWY015993
	for <linux-mm@kvack.org>; Wed, 26 Sep 2007 03:17:14 +1000
Message-ID: <46F942D6.3020103@linux.vnet.ibm.com>
Date: Tue, 25 Sep 2007 22:48:14 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [patch -mm 6/5] memcontrol: move mm_cgroup to header file
References: <alpine.DEB.0.9999.0709250035570.11015@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.0.9999.0709250035570.11015@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

David Rientjes wrote:
> Inline functions must preceed their use, so mm_cgroup() should be defined
> in linux/memcontrol.h.
> 
> include/linux/memcontrol.h:48: warning: 'mm_cgroup' declared inline after
> 	being called
> include/linux/memcontrol.h:48: warning: previous declaration of
> 	'mm_cgroup' was here
> 
> Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
> Signed-off-by: David Rientjes <rientjes@google.com>

Is this a new warning or have you seen this earlier. I don't see the
warning in any of the versions upto 2.6.23-rc7-mm1. I'll check
the compilation output again and of-course 2.6.23-rc8-mm1


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
