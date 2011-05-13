Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 260A96B0025
	for <linux-mm@kvack.org>; Fri, 13 May 2011 06:14:16 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 8CFBD3EE0BD
	for <linux-mm@kvack.org>; Fri, 13 May 2011 19:14:12 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 72E1045DE93
	for <linux-mm@kvack.org>; Fri, 13 May 2011 19:14:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B0B345DE91
	for <linux-mm@kvack.org>; Fri, 13 May 2011 19:14:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E6DAE08002
	for <linux-mm@kvack.org>; Fri, 13 May 2011 19:14:12 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1A3AF1DB8037
	for <linux-mm@kvack.org>; Fri, 13 May 2011 19:14:12 +0900 (JST)
Message-ID: <4DCD04D5.80500@jp.fujitsu.com>
Date: Fri, 13 May 2011 19:15:49 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] oom: kill younger process first
References: <20110509182110.167F.A69D9226@jp.fujitsu.com> <20110510171335.16A7.A69D9226@jp.fujitsu.com> <20110510171641.16AF.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1105101629590.12477@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1105101629590.12477@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: CAI Qian <caiqian@redhat.com>, avagin@gmail.com, Andrey Vagin <avagin@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>

(2011/05/11 8:31), David Rientjes wrote:
> On Tue, 10 May 2011, KOSAKI Motohiro wrote:
>
>> This patch introduces do_each_thread_reverse() and
>> select_bad_process() uses it. The benefits are two,
>> 1) oom-killer can kill younger process than older if
>> they have a same oom score. Usually younger process
>> is less important. 2) younger task often have PF_EXITING
>> because shell script makes a lot of short lived processes.
>> Reverse order search can detect it faster.
>>
>
> I like this change, thanks!  I'm suprised we haven't needed a
> do_each_thread_reverse() in the past somewhere else in the kernel.
>
> Could you update the comment about do_each_thread() not being break-safe
> in the second version, though?

ok.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
