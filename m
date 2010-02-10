Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 7D7296B00A2
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 12:08:59 -0500 (EST)
Message-ID: <4B72E81D.9020409@redhat.com>
Date: Wed, 10 Feb 2010 12:08:45 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 1/7 -mm] oom: filter tasks not sharing the same cpuset
References: <alpine.DEB.2.00.1002100224210.8001@chino.kir.corp.google.com> <alpine.DEB.2.00.1002100227590.8001@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1002100227590.8001@chino.kir.corp.google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 02/10/2010 11:32 AM, David Rientjes wrote:
> Tasks that do not share the same set of allowed nodes with the task that
> triggered the oom should not be considered as candidates for oom kill.
>
> Tasks in other cpusets with a disjoint set of mems would be unfairly
> penalized otherwise because of oom conditions elsewhere; an extreme
> example could unfairly kill all other applications on the system if a
> single task in a user's cpuset sets itself to OOM_DISABLE and then uses
> more memory than allowed.
>
> Killing tasks outside of current's cpuset rarely would free memory for
> current anyway.
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
