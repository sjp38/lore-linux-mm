Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3AC266B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 21:21:56 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 9512D3EE0C3
	for <linux-mm@kvack.org>; Tue, 24 May 2011 10:21:53 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7880945DE96
	for <linux-mm@kvack.org>; Tue, 24 May 2011 10:21:53 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 602DF45DE94
	for <linux-mm@kvack.org>; Tue, 24 May 2011 10:21:53 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 41200E78004
	for <linux-mm@kvack.org>; Tue, 24 May 2011 10:21:53 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E56421DB803E
	for <linux-mm@kvack.org>; Tue, 24 May 2011 10:21:52 +0900 (JST)
Message-ID: <4DDB082C.2030809@jp.fujitsu.com>
Date: Tue, 24 May 2011 10:21:48 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/5] oom: oom-killer don't use proportion of system-ram
 internally
References: <4DD61F80.1020505@jp.fujitsu.com> <4DD6204D.5020109@jp.fujitsu.com> <alpine.DEB.2.00.1105231522410.17840@chino.kir.corp.google.com> <alpine.DEB.2.00.1105231547060.17840@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1105231547060.17840@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com
Cc: caiqian@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, oleg@redhat.com

(2011/05/24 7:48), David Rientjes wrote:
> On Mon, 23 May 2011, David Rientjes wrote:
>
>> I already suggested an alternative patch to CAI Qian to greatly increase
>> the granularity of the oom score from a range of 0-1000 to 0-10000 to
>> differentiate between tasks within 0.01% of available memory (16MB on CAI
>> Qian's 16GB system).  I'll propose this officially in a separate email.
>>
>
> This is an alternative patch as earlier proposed with suggested
> improvements from Minchan.  CAI, would it be possible to test this out on
> your usecase?
>
> I'm indifferent to the actual scale of OOM_SCORE_MAX_FACTOR; it could be
> 10 as proposed in this patch or even increased higher for higher
> resolution.

I did explain why your proposal is unacceptable.

http://www.gossamer-threads.com/lists/linux/kernel/1378837#1378837

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
