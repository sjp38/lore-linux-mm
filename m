Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id F3AE36B007E
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 23:10:47 -0500 (EST)
Message-ID: <4B73833D.5070008@redhat.com>
Date: Wed, 10 Feb 2010 23:10:37 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 4/7 -mm] oom: badness heuristic rewrite
References: <alpine.DEB.2.00.1002100224210.8001@chino.kir.corp.google.com> <alpine.DEB.2.00.1002100228540.8001@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1002100228540.8001@chino.kir.corp.google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 02/10/2010 11:32 AM, David Rientjes wrote:

> OOM_ADJUST_MIN and OOM_ADJUST_MAX have been exported to userspace since
> 2006 via include/linux/oom.h.  This alters their values from -16 to -1000
> and from +15 to +1000, respectively.

That seems like a bad idea.  Google may have the luxury of
being able to recompile all its in-house applications, but
this will not be true for many other users of /proc/<pid>/oom_adj

> +/*
> + * Tasks that fork a very large number of children with seperate address spaces
> + * may be the result of a bug, user error, or a malicious application.  The oom
> + * killer assesses a penalty equaling

It could also be the result of the system getting many client
connections - think of overloaded mail, web or database servers.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
