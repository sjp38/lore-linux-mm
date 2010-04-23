Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id C0D726B01F0
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 04:45:28 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [10.3.21.1])
	by smtp-out.google.com with ESMTP id o3N8jQlv028766
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 01:45:26 -0700
Received: from pvg4 (pvg4.prod.google.com [10.241.210.132])
	by hpaq1.eem.corp.google.com with ESMTP id o3N8jJlM032485
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 10:45:24 +0200
Received: by pvg4 with SMTP id 4so377166pvg.29
        for <linux-mm@kvack.org>; Fri, 23 Apr 2010 01:45:22 -0700 (PDT)
Date: Fri, 23 Apr 2010 01:45:17 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mm: fix bugs of mpol_rebind_nodemask()
In-Reply-To: <4BD0F797.6020704@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1004230141400.2190@chino.kir.corp.google.com>
References: <4BD05929.8040900@cn.fujitsu.com> <alpine.DEB.2.00.1004221415090.25350@chino.kir.corp.google.com> <4BD0F797.6020704@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Miao Xie <miaox@cn.fujitsu.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>, Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 23 Apr 2010, Miao Xie wrote:

> Suppose the current mempolicy nodes is 0-2, we can remap it from 0-2 to 2,
> then we can remap it from 2 to 1, but we can't remap it from 2 to 0-2.
> 
> that is to say it can't be remaped to a large set of allowed nodes, and the task
> just can use the small set of nodes for ever, even the large set of nodes is allowed,
> I think it is unreasonable.
> 

That's been the behavior for at least three years so changing it from 
under the applications isn't acceptable, see 
Documentation/vm/numa_memory_policy.txt regarding mempolicy rebinds and 
the two flags that are defined that can be used to adjust the behavior.

The pol->v.nodes = nodes_empty(tmp) ? *nodes : tmp fix is welcome, 
however, as a standalone patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
