Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B46796B0012
	for <linux-mm@kvack.org>; Tue, 31 May 2011 00:33:01 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id EA34F3EE0C3
	for <linux-mm@kvack.org>; Tue, 31 May 2011 13:32:53 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D143E45DF5E
	for <linux-mm@kvack.org>; Tue, 31 May 2011 13:32:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B60AA45DF5B
	for <linux-mm@kvack.org>; Tue, 31 May 2011 13:32:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A0D58E08008
	for <linux-mm@kvack.org>; Tue, 31 May 2011 13:32:53 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 649CF1DB803C
	for <linux-mm@kvack.org>; Tue, 31 May 2011 13:32:53 +0900 (JST)
Message-ID: <4DE46F69.4000205@jp.fujitsu.com>
Date: Tue, 31 May 2011 13:32:41 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/5] Fix oom killer doesn't work at all if system have
 > gigabytes memory  (aka CAI founded issue)
References: <2135926037.315785.1306805582148.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com> <4DE46A4B.40401@jp.fujitsu.com>
In-Reply-To: <4DE46A4B.40401@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: caiqian@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, rientjes@google.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, oleg@redhat.com

(2011/05/31 13:10), KOSAKI Motohiro wrote:
> (2011/05/31 10:33), CAI Qian wrote:
>> Hello,
>>
>> Have tested those patches rebased from KOSAKI for the latest mainline.
>> It still killed random processes and recevied a panic at the end by
>> using root user. The full oom output can be found here.
>> http://people.redhat.com/qcai/oom
> 
> You ran fork-bomb as root. Therefore unprivileged process was killed at first.
> It's no random. It's intentional and desirable. I mean
> 
> - If you run the same progream as non-root, python will be killed at first.
>   Because it consume a lot of memory than daemons.
> - If you run the same program as root, non root process and privilege explicit
>   dropping processes (e.g. irqbalance) will be killed at first.

I mean, oom-killer start to kill python after killing all unprivilege process
in this case. Please wait & see ahile after sequence.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
