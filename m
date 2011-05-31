Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6C4746B0012
	for <linux-mm@kvack.org>; Tue, 31 May 2011 03:57:07 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 12C483EE0C2
	for <linux-mm@kvack.org>; Tue, 31 May 2011 16:57:02 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E6A3845DF56
	for <linux-mm@kvack.org>; Tue, 31 May 2011 16:57:01 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id CFCFE45DF54
	for <linux-mm@kvack.org>; Tue, 31 May 2011 16:57:01 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C495A1DB803A
	for <linux-mm@kvack.org>; Tue, 31 May 2011 16:57:01 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 92E831DB802C
	for <linux-mm@kvack.org>; Tue, 31 May 2011 16:57:01 +0900 (JST)
Message-ID: <4DE49F44.10809@jp.fujitsu.com>
Date: Tue, 31 May 2011 16:56:52 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/5] Fix oom killer doesn't work at all if system have
 > gigabytes memory  (aka CAI founded issue)
References: <1685840459.318633.1306828245496.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <1685840459.318633.1306828245496.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: caiqian@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, rientjes@google.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, oleg@redhat.com

(2011/05/31 16:50), CAI Qian wrote:
> 
> 
> ----- Original Message -----
>>>> - If you run the same program as root, non root process and
>>>> privilege
>>>> explicit
>>>> dropping processes (e.g. irqbalance) will be killed at first.
>>> Hmm, at least there were some programs were root processes but were
>>> killed
>>> first.
>>> [ pid] ppid uid total_vm rss swap score_adj name
>>> [ 5720] 5353 0 24421 257 0 0 sshd
>>> [ 5353] 1 0 15998 189 0 0 sshd
>>> [ 5451] 1 0 19648 235 0 0 master
>>> [ 1626] 1 0 2287 129 0 0 dhclient
>>
>> Hi
>>
>> I can't reproduce this too. Are you sure these processes have a full
>> root privilege?
>> I've made new debugging patch. After applying following patch, do
>> these processes show
>> cap=1?
> No, all of them had cap=0. Wondering why something like sshd not been
> made cap=1 to avoid early oom kill.

Then, I believe your distro applying distro specific patch to ssh.
Which distro are you using now?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
