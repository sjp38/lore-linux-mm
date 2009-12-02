Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E473560021B
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 21:05:41 -0500 (EST)
Message-ID: <4B15CB48.6000509@redhat.com>
Date: Tue, 01 Dec 2009 21:04:56 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC] high system time & lock contention running large mixed
 workload
References: <1259618429.2345.3.camel@dhcp-100-19-198.bos.redhat.com> <20091201100444.GN30235@random.random> <20091201212357.5C3A.A69D9226@jp.fujitsu.com> <20091201124619.GO30235@random.random>
In-Reply-To: <20091201124619.GO30235@random.random>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Larry Woodman <lwoodman@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> I taken number 7 purely as mentioned by Larry about old code, but I
> don't mind what is the actual breakpoint level where we start to send
> the ipi flood to destroy all userland tlbs mapping the page so the
> young bit can be set by the cpu on the old pte. If you agree with me
> at the lowest priority we shouldn't flood ipi and destroy tlb when
> there's plenty of clean unmapped clean cache, we already agree ;). If
> that's 7 or DEV_PRIORITY-1, that's ok. All I care is that it escalates
> gradually, first clean cache and re-activate mapped pages, then when
> we're low on clean cache we start to check ptes and unmap whatever is
> not found referenced.
>    
>
The code already does what you propose.

It takes a heavy AIM7 run for Larry to run into the
lock contention issue.  I suspect that the page cache
was already very small by the time the lock contention
issue was triggered.

Larry, do you have any more info on the state of the
VM when you see the lock contention?

Also, do you have the latest patches to shrink_list()
by Kosaki and me applied?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
