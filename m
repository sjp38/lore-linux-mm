Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3E96B6B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 21:54:05 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 59D3A3EE0BC
	for <linux-mm@kvack.org>; Tue, 24 May 2011 10:54:02 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 409B845DE61
	for <linux-mm@kvack.org>; Tue, 24 May 2011 10:54:02 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 27A0845DE4E
	for <linux-mm@kvack.org>; Tue, 24 May 2011 10:54:02 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 16040E08002
	for <linux-mm@kvack.org>; Tue, 24 May 2011 10:54:02 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D155A1DB803A
	for <linux-mm@kvack.org>; Tue, 24 May 2011 10:54:01 +0900 (JST)
Message-ID: <4DDB0FB2.9050300@jp.fujitsu.com>
Date: Tue, 24 May 2011 10:53:54 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] oom: don't kill random process
References: <4DD61F80.1020505@jp.fujitsu.com>	<4DD6207E.1070300@jp.fujitsu.com> <BANLkTinaHki1oA4O3+FsoPDtFTLfqwRadA@mail.gmail.com>
In-Reply-To: <BANLkTinaHki1oA4O3+FsoPDtFTLfqwRadA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan.kim@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, caiqian@redhat.com, rientjes@google.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, oleg@redhat.com

>> +       /*
>> +        * chosen_point==1 may be a sign that root privilege bonus is too large
>> +        * and we choose wrong task. Let's recalculate oom score without the
>> +        * dubious bonus.
>> +        */
>> +       if (protect_root&&  (chosen_points == 1)) {
>> +               protect_root = 0;
>> +               goto retry;
>> +       }
>
> The idea is good to me.
> But once we meet it, should we give up protecting root privileged processes?
> How about decaying bonus point?

After applying my patch, unprivileged process never get score-1. (note, mapping
anon pages naturally makes to increase nr_ptes)

Then, decaying don't make any accuracy. Am I missing something?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
