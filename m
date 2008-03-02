Date: Sun, 02 Mar 2008 19:35:44 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 11/21] (NEW) more aggressively use lumpy reclaim
In-Reply-To: <20080228192928.954667833@redhat.com>
References: <20080228192908.126720629@redhat.com> <20080228192928.954667833@redhat.com>
Message-Id: <20080302193024.1E72.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi

I think this patch is very good improvement.
but it is not related to split lru.

Why don't you separate this patch?
IMHO treat as independent patch is better.

Thanks.

> During an AIM7 run on a 16GB system, fork started failing around
> 32000 threads, despite the system having plenty of free swap and
> 15GB of pageable memory.
> 
> If normal pageout does not result in contiguous free pages for
> kernel stacks, fall back to lumpy reclaim instead of failing fork
> or doing excessive pageout IO.
> 
> I do not know whether this change is needed due to the extreme
> stress test or because the inactive list is a smaller fraction
> of system memory on huge systems.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
