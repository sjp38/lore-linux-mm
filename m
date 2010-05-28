Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5C9C56B01C3
	for <linux-mm@kvack.org>; Fri, 28 May 2010 11:35:53 -0400 (EDT)
Received: by gwb19 with SMTP id 19so1130287gwb.14
        for <linux-mm@kvack.org>; Fri, 28 May 2010 08:35:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1275060103.27810.9651.camel@twins>
References: <20100528143605.7E2A.A69D9226@jp.fujitsu.com>
	<AANLkTikB-8Qu03VrA5Z0LMXM_alSV7SLqzl-MmiLmFGv@mail.gmail.com>
	<20100528145329.7E2D.A69D9226@jp.fujitsu.com>
	<20100528125305.GE11364@uudg.org>
	<20100528140623.GA11041@barrios-desktop>
	<20100528143617.GF11364@uudg.org>
	<20100528151249.GB12035@barrios-desktop>
	<1275060103.27810.9651.camel@twins>
Date: Sat, 29 May 2010 00:35:50 +0900
Message-ID: <AANLkTinoTgYfywq1S6UV-n7npzk4xyQZ2PMT5LDkaBCQ@mail.gmail.com>
Subject: Re: [RFC] oom-kill: give the dying task a higher priority
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, balbir@linux.vnet.ibm.com, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, williams@redhat.com
List-ID: <linux-mm.kvack.org>

On Sat, May 29, 2010 at 12:21 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Sat, 2010-05-29 at 00:12 +0900, Minchan Kim wrote:
>> I think highest RT proirity ins't good solution.
>> As I mentiond, Some RT functions don't want to be preempted by other processes
>> which cause memory pressure. It makes RT task broken.
>
> All the patches I've seen use MAX_RT_PRIO-1, which is actually FIFO-1,
> which is the lowest RT priority.

Stupid me. I confused that until now.
That's exactly what I want.


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
