Received: from mailrelay01.cce.cpqcorp.net (mailrelay01.cce.cpqcorp.net [16.47.68.171])
	by ccerelbas02.cce.hp.com (Postfix) with ESMTP id B0DC934577
	for <linux-mm@kvack.org>; Fri, 10 Mar 2006 13:59:57 -0600 (CST)
Received: from anw.zk3.dec.com (wasted.zk3.dec.com [16.140.32.3])
	by mailrelay01.cce.cpqcorp.net (Postfix) with ESMTP id 79B8C1675
	for <linux-mm@kvack.org>; Fri, 10 Mar 2006 13:59:57 -0600 (CST)
Subject: Re: [PATCH/RFC] AutoPage Migration - V0.1 - 6/8 hook sched migrate
	to memory migration
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reply-To: lee.schermerhorn@hp.com
In-Reply-To: <1142020335.5204.26.camel@localhost.localdomain>
References: <1142020335.5204.26.camel@localhost.localdomain>
Content-Type: text/plain
Date: Fri, 10 Mar 2006 14:59:37 -0500
Message-Id: <1142020778.5204.35.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2006-03-10 at 14:52 -0500, Lee Schermerhorn wrote:
> AutoPage Migration - V0.1 - 6/8 hook sched migrate to memory migration
> 
> Add check for internode migration to scheduler -- in most places
> where a new cpu is assigned via set_task_cpu().  If MIGRATION is
> configured, and sched_migrate_memory is enabled [and this is a
> user space task], the check will set "migration pending" for the
> task if the destination cpu is on a different cpu from the last
:-(                                              ^-node
> cpu to which the task was assigned.  Migration of affected pages
> [those with default policy] will occur when the task returns to
> user space.
> 
> Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
