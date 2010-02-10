Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C0AD26B0071
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 17:39:43 -0500 (EST)
Message-ID: <4B731CA6.3030304@redhat.com>
Date: Wed, 10 Feb 2010 15:52:54 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 2/7 -mm] oom: sacrifice child with highest badness score
 for parent
References: <alpine.DEB.2.00.1002100224210.8001@chino.kir.corp.google.com> <alpine.DEB.2.00.1002100228240.8001@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1002100228240.8001@chino.kir.corp.google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 02/10/2010 11:32 AM, David Rientjes wrote:
> When a task is chosen for oom kill, the oom killer first attempts to
> sacrifice a child not sharing its parent's memory instead.
> Unfortunately, this often kills in a seemingly random fashion based on
> the ordering of the selected task's child list.  Additionally, it is not
> guaranteed at all to free a large amount of memory that we need to
> prevent additional oom killing in the very near future.
>
> Instead, we now only attempt to sacrifice the worst child not sharing its
> parent's memory, if one exists.  The worst child is indicated with the
> highest badness() score.  This serves two advantages: we kill a
> memory-hogging task more often, and we allow the configurable
> /proc/pid/oom_adj value to be considered as a factor in which child to
> kill.
>
> Reviewers may observe that the previous implementation would iterate
> through the children and attempt to kill each until one was successful
> and then the parent if none were found while the new code simply kills
> the most memory-hogging task or the parent.  Note that the only time
> oom_kill_task() fails, however, is when a child does not have an mm or
> has a /proc/pid/oom_adj of OOM_DISABLE.  badness() returns 0 for both
> cases, so the final oom_kill_task() will always succeed.
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
