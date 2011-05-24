Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 752326B0011
	for <linux-mm@kvack.org>; Tue, 24 May 2011 04:49:42 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 6B0DF3EE0C0
	for <linux-mm@kvack.org>; Tue, 24 May 2011 17:49:39 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 54FC945DF68
	for <linux-mm@kvack.org>; Tue, 24 May 2011 17:49:39 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 367A845DF69
	for <linux-mm@kvack.org>; Tue, 24 May 2011 17:49:39 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2AAB4EF8002
	for <linux-mm@kvack.org>; Tue, 24 May 2011 17:49:39 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E9CCFE08002
	for <linux-mm@kvack.org>; Tue, 24 May 2011 17:49:38 +0900 (JST)
Message-ID: <4DDB711B.8010408@jp.fujitsu.com>
Date: Tue, 24 May 2011 17:49:31 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] oom: don't kill random process
References: <4DD61F80.1020505@jp.fujitsu.com>	<4DD6207E.1070300@jp.fujitsu.com>	<BANLkTinaHki1oA4O3+FsoPDtFTLfqwRadA@mail.gmail.com>	<4DDB0FB2.9050300@jp.fujitsu.com> <BANLkTinKm=m8zdPGN0Trpy4HtEFyxMYzPA@mail.gmail.com>
In-Reply-To: <BANLkTinKm=m8zdPGN0Trpy4HtEFyxMYzPA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan.kim@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, caiqian@redhat.com, rientjes@google.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, oleg@redhat.com

(2011/05/24 17:46), Minchan Kim wrote:
> On Tue, May 24, 2011 at 10:53 AM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
>>>> +       /*
>>>> +        * chosen_point==1 may be a sign that root privilege bonus is too
>>>> large
>>>> +        * and we choose wrong task. Let's recalculate oom score without
>>>> the
>>>> +        * dubious bonus.
>>>> +        */
>>>> +       if (protect_root&&  (chosen_points == 1)) {
>>>> +               protect_root = 0;
>>>> +               goto retry;
>>>> +       }
>>>
>>> The idea is good to me.
>>> But once we meet it, should we give up protecting root privileged
>>> processes?
>>> How about decaying bonus point?
>>
>> After applying my patch, unprivileged process never get score-1. (note,
>> mapping
>> anon pages naturally makes to increase nr_ptes)
> 
> Hmm, If I understand your code correctly, unprivileged process can get
> a score 1 by 3% bonus.

3% bonus is for privileged process. :)


> So after all, we can get a chosen_point with 1.
> Why I get a chosen_point with 1 is as bonus is rather big, I think.
> So I would like to use small bonus than first iteration(ie, decay bonus).
> 
>>
>> Then, decaying don't make any accuracy. Am I missing something?
> 
> Maybe I miss something.  :(
> 
> 
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
