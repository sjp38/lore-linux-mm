Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id m1DHMgcX004048
	for <linux-mm@kvack.org>; Wed, 13 Feb 2008 22:52:42 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1DHMgQG712836
	for <linux-mm@kvack.org>; Wed, 13 Feb 2008 22:52:42 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id m1DHMf58021330
	for <linux-mm@kvack.org>; Wed, 13 Feb 2008 17:22:42 GMT
Message-ID: <47B326BA.7040000@linux.vnet.ibm.com>
Date: Wed, 13 Feb 2008 22:49:54 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC] [PATCH 1/4] Modify resource counters to add soft limit
 support
References: <20080213151201.7529.53642.sendpatchset@localhost.localdomain> <20080213151214.7529.3954.sendpatchset@localhost.localdomain> <47B324F4.1050102@openvz.org>
In-Reply-To: <47B324F4.1050102@openvz.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Emelyanov <xemul@openvz.org>
Cc: linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Nick Piggin <nickpiggin@yahoo.com.au>, "Eric W. Biederman" <ebiederm@xmission.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Rik Van Riel <riel@redhat.com>, Herbert Poetzl <herbert@13thfloor.at>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Pavel Emelyanov wrote:
> Balbir Singh wrote:

> Resource counter accounts for arbitrary resource. Memory pressure
> and memory reclamation both only make sense in case we're dealing
> with memory controller. Please, remove this comment or move it to
> memcontrol.c.
> 

Yes, they always have. The concept of soft limits, hard limits, guarantees
applies to all resources. Why do you say they apply only to memory controller? I
can change the comment to make the definition generic for all resources.


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
