Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 25DF56B0011
	for <linux-mm@kvack.org>; Tue, 24 May 2011 05:38:39 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 61BC83EE0C2
	for <linux-mm@kvack.org>; Tue, 24 May 2011 18:38:35 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 464FE45DEC3
	for <linux-mm@kvack.org>; Tue, 24 May 2011 18:38:35 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2BAEB45DE9C
	for <linux-mm@kvack.org>; Tue, 24 May 2011 18:38:35 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F37EE78003
	for <linux-mm@kvack.org>; Tue, 24 May 2011 18:38:35 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D9D251DB803B
	for <linux-mm@kvack.org>; Tue, 24 May 2011 18:38:34 +0900 (JST)
Message-ID: <4DDB7C94.1090805@jp.fujitsu.com>
Date: Tue, 24 May 2011 18:38:28 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] oom: don't kill random process
References: <4DD61F80.1020505@jp.fujitsu.com>	<4DD6207E.1070300@jp.fujitsu.com>	<BANLkTinaHki1oA4O3+FsoPDtFTLfqwRadA@mail.gmail.com>	<4DDB0FB2.9050300@jp.fujitsu.com>	<BANLkTinKm=m8zdPGN0Trpy4HtEFyxMYzPA@mail.gmail.com>	<4DDB711B.8010408@jp.fujitsu.com>	<BANLkTik5tXv+k9tk2egXgmBRzcBD5Avjkw@mail.gmail.com>	<4DDB75D8.1000804@jp.fujitsu.com> <BANLkTime4C8nk0TBOfd2NT4mEEtLN6ZYaQ@mail.gmail.com>
In-Reply-To: <BANLkTime4C8nk0TBOfd2NT4mEEtLN6ZYaQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan.kim@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, caiqian@redhat.com, rientjes@google.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, oleg@redhat.com

(2011/05/24 18:20), Minchan Kim wrote:
> On Tue, May 24, 2011 at 6:09 PM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
>>>>> Hmm, If I understand your code correctly, unprivileged process can get
>>>>> a score 1 by 3% bonus.
>>>>
>>>> 3% bonus is for privileged process. :)
>>>
>>> OMG. Typo.
>>> Anyway, my point is following as.
>>> If chose_point is 1, it means root bonus is rather big. Right?
>>> If is is, your patch does second loop with completely ignore of bonus
>>> for root privileged process.
>>> My point is that let's not ignore bonus completely. Instead of it,
>>> let's recalculate 1.5% for example.
>>
>> 1) unpriviledged process can't get score 1 (because at least a process need one
>>   anon, one file and two or more ptes).
>> 2) then, score=1 mean all processes in the system are privileged. thus decay won't help.
>>
>> IOW, never happen privileged and unprivileged score in this case.
> 
> I am blind. Thanks for open my eyes, KOSAKI.

No. Your review is very cute. Thank you for attempting this!



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
