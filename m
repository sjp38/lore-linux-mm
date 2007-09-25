Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id l8PHmh90003919
	for <linux-mm@kvack.org>; Wed, 26 Sep 2007 03:48:43 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8PHqFK3203300
	for <linux-mm@kvack.org>; Wed, 26 Sep 2007 03:52:15 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8PHmOYj025860
	for <linux-mm@kvack.org>; Wed, 26 Sep 2007 03:48:25 +1000
Message-ID: <46F949DC.1070806@linux.vnet.ibm.com>
Date: Tue, 25 Sep 2007 23:18:12 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [patch -mm 7/5] oom: filter tasklist dump by mem_cgroup
References: <alpine.DEB.0.9999.0709250035570.11015@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709250037030.11015@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.0.9999.0709250037030.11015@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

David Rientjes wrote:
> If an OOM was triggered as a result a cgroup's memory controller, the
> tasklist shall be filtered to exclude tasks that are not a member of the
> same group.
> 
> Creates a helper function to return non-zero if a task is a member of a
> mem_cgroup:
> 
> 	int task_in_mem_cgroup(const struct task_struct *task,
> 			       const struct mem_cgroup *mem);
> 
> Cc: Christoph Lameter <clameter@sgi.com>
> Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
> Signed-off-by: David Rientjes <rientjes@google.com>

Thanks for doing this. The number of parameters to OOM kill
have grown, may at the time of the next addition of parameter,
we should consider using a structure similar to scan_control
and pass the structure instead of all the parameters.


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
