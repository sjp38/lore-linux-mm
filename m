Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 499E86B007B
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 21:47:43 -0500 (EST)
Message-ID: <4B733785.7060608@redhat.com>
Date: Wed, 10 Feb 2010 17:47:33 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 3/7 -mm] oom: select task from tasklist for mempolicy
 ooms
References: <alpine.DEB.2.00.1002100224210.8001@chino.kir.corp.google.com> <alpine.DEB.2.00.1002100228370.8001@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1002100228370.8001@chino.kir.corp.google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 02/10/2010 11:32 AM, David Rientjes wrote:
> The oom killer presently kills current whenever there is no more memory
> free or reclaimable on its mempolicy's nodes.  There is no guarantee that
> current is a memory-hogging task or that killing it will free any
> substantial amount of memory, however.
>
> In such situations, it is better to scan the tasklist for nodes that are
> allowed to allocate on current's set of nodes and kill the task with the
> highest badness() score.  This ensures that the most memory-hogging task,
> or the one configured by the user with /proc/pid/oom_adj, is always
> selected in such scenarios.
>
> Signed-off-by: David Rientjes<rientjes@google.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
