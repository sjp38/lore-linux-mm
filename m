Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id E29AB6B0011
	for <linux-mm@kvack.org>; Tue, 24 May 2011 05:09:53 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 3B9F43EE0AE
	for <linux-mm@kvack.org>; Tue, 24 May 2011 18:09:51 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2399145DF47
	for <linux-mm@kvack.org>; Tue, 24 May 2011 18:09:51 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0BCDD45DF46
	for <linux-mm@kvack.org>; Tue, 24 May 2011 18:09:51 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 006281DB8038
	for <linux-mm@kvack.org>; Tue, 24 May 2011 18:09:51 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C21BA1DB8037
	for <linux-mm@kvack.org>; Tue, 24 May 2011 18:09:50 +0900 (JST)
Message-ID: <4DDB75D8.1000804@jp.fujitsu.com>
Date: Tue, 24 May 2011 18:09:44 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] oom: don't kill random process
References: <4DD61F80.1020505@jp.fujitsu.com>	<4DD6207E.1070300@jp.fujitsu.com>	<BANLkTinaHki1oA4O3+FsoPDtFTLfqwRadA@mail.gmail.com>	<4DDB0FB2.9050300@jp.fujitsu.com>	<BANLkTinKm=m8zdPGN0Trpy4HtEFyxMYzPA@mail.gmail.com>	<4DDB711B.8010408@jp.fujitsu.com> <BANLkTik5tXv+k9tk2egXgmBRzcBD5Avjkw@mail.gmail.com>
In-Reply-To: <BANLkTik5tXv+k9tk2egXgmBRzcBD5Avjkw@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan.kim@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, caiqian@redhat.com, rientjes@google.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, oleg@redhat.com

>>> Hmm, If I understand your code correctly, unprivileged process can get
>>> a score 1 by 3% bonus.
>>
>> 3% bonus is for privileged process. :)
> 
> OMG. Typo.
> Anyway, my point is following as.
> If chose_point is 1, it means root bonus is rather big. Right?
> If is is, your patch does second loop with completely ignore of bonus
> for root privileged process.
> My point is that let's not ignore bonus completely. Instead of it,
> let's recalculate 1.5% for example.

1) unpriviledged process can't get score 1 (because at least a process need one
   anon, one file and two or more ptes).
2) then, score=1 mean all processes in the system are privileged. thus decay won't help.

IOW, never happen privileged and unprivileged score in this case.


> 
> But I don't insist on my idea.
> Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
