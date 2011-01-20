Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 880418D003A
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 21:58:35 -0500 (EST)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p0K2wRO9031206
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 18:58:27 -0800
Received: from pvg12 (pvg12.prod.google.com [10.241.210.140])
	by hpaq11.eem.corp.google.com with ESMTP id p0K2wO3n006328
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 18:58:26 -0800
Received: by pvg12 with SMTP id 12so32257pvg.26
        for <linux-mm@kvack.org>; Wed, 19 Jan 2011 18:58:24 -0800 (PST)
Date: Wed, 19 Jan 2011 18:58:21 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/3] oom: suppress nodes that are not allowed from meminfo
 on oom kill
In-Reply-To: <alpine.DEB.2.00.1101111712190.20611@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1101191857550.32605@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1101111712190.20611@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 11 Jan 2011, David Rientjes wrote:

> The oom killer is extremely verbose for machines with a large number of
> cpus and/or nodes.  This verbosity can often be harmful if it causes
> other important messages to be scrolled from the kernel log and incurs a
> signicant time delay, specifically for kernels with
> CONFIG_NODES_SHIFT > 8.
> 
> This patch causes only memory information to be displayed for nodes that
> are allowed by current's cpuset when dumping the VM state.  Information
> for all other nodes is irrelevant to the oom condition; we don't care if
> there's an abundance of memory elsewhere if we can't access it.
> 
> This only affects the behavior of dumping memory information when an oom
> is triggered.  Other dumps, such as for sysrq+m, still display the
> unfiltered form when using the existing show_mem() interface.
> 
> Additionally, the per-cpu pageset statistics are extremely verbose in oom
> killer output, so it is now suppressed.  This removes
> 
> 	nodes_weight(current->mems_allowed) * (1 + nr_cpus)
> 
> lines from the oom killer output.
> 
> Callers may use __show_mem(SHOW_MEM_FILTER_NODES) to filter disallowed
> nodes.

Are there any objections to merging this series in -mm?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
