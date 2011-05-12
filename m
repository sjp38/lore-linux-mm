Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6F0616B0011
	for <linux-mm@kvack.org>; Wed, 11 May 2011 21:30:47 -0400 (EDT)
Received: by qwa26 with SMTP id 26so812194qwa.14
        for <linux-mm@kvack.org>; Wed, 11 May 2011 18:30:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110512095243.c57e3e83.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110509182110.167F.A69D9226@jp.fujitsu.com>
	<20110510171335.16A7.A69D9226@jp.fujitsu.com>
	<20110510171641.16AF.A69D9226@jp.fujitsu.com>
	<20110512095243.c57e3e83.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 12 May 2011 10:30:45 +0900
Message-ID: <BANLkTi=ya1rAqC+nMPHkBaMsoXpsCeHH=w@mail.gmail.com>
Subject: Re: [PATCH 2/4] oom: kill younger process first
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, CAI Qian <caiqian@redhat.com>, avagin@gmail.com, Andrey Vagin <avagin@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>

Hi Kame,

On Thu, May 12, 2011 at 9:52 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 10 May 2011 17:15:01 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
>
>> This patch introduces do_each_thread_reverse() and
>> select_bad_process() uses it. The benefits are two,
>> 1) oom-killer can kill younger process than older if
>> they have a same oom score. Usually younger process
>> is less important. 2) younger task often have PF_EXITING
>> because shell script makes a lot of short lived processes.
>> Reverse order search can detect it faster.
>>
>> Reported-by: CAI Qian <caiqian@redhat.com>
>> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>
> IIUC, for_each_thread() can be called under rcu_read_lock() but
> for_each_thread_reverse() must be under tasklist_lock.

Just out of curiosity.
You mentioned it when I sent forkbomb killer patch. :)
>From at that time, I can't understand why we need holding
tasklist_lock not rcu_read_lock. Sorry for the dumb question.

At present, it seems that someone uses tasklist_lock and others uses
rcu_read_lock. But I can't find any rule for that.

Could you elaborate it, please?
Doesn't it need document about it?

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
