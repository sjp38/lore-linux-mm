Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id BC4F66B0012
	for <linux-mm@kvack.org>; Mon, 30 May 2011 23:58:41 -0400 (EDT)
Received: by yib18 with SMTP id 18so2040695yib.14
        for <linux-mm@kvack.org>; Mon, 30 May 2011 20:58:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110531121815.67523361.kamezawa.hiroyu@jp.fujitsu.com>
References: <1306774744.4061.5.camel@localhost.localdomain>
	<20110531083859.98e4ff43.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTinTqijGxCpZ_nRwWZHYsR-u2zojZA@mail.gmail.com>
	<20110531121815.67523361.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 31 May 2011 09:58:40 +0600
Message-ID: <BANLkTiksAjyCBAPdCB58tAWhXcdqXM4EcA@mail.gmail.com>
Subject: Re: [PATCH] mm, vmstat: Use cond_resched only when !CONFIG_PREEMPT
From: Rakib Mullick <rakib.mullick@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Christoph Lameter <cl@linux.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Tue, May 31, 2011 at 9:18 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 31 May 2011 09:13:47 +0600
> Rakib Mullick <rakib.mullick@gmail.com> wrote:
>
>> On Tue, May 31, 2011 at 5:38 AM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > On Mon, 30 May 2011 22:59:04 +0600
>> > Rakib Mullick <rakib.mullick@gmail.com> wrote:
>> >
>> >> commit 468fd62ed9 (vmstats: add cond_resched() to refresh_cpu_vm_stat=
s()) added cond_resched() in refresh_cpu_vm_stats. Purpose of that patch wa=
s to allow other threads to run in non-preemptive case. This patch, makes s=
ure that cond_resched() gets called when !CONFIG_PREEMPT is set. In a preem=
ptiable kernel we don't need to call cond_resched().
>> >>
>> >> Signed-off-by: Rakib Mullick <rakib.mullick@gmail.com>
>> >
>> > Hmm, what benefit do we get by adding this extra #ifdef in the code di=
rectly ?
>> > Other cond_resched() callers are not guilty in !CONFIG_PREEMPT ?
>> >
>> Well, in preemptible kernel this context will get preempted if
>> requires, so we don't need cond_resched(). If you checkout the git log
>> of the mentioned commit, you'll find the explanation. It says:
>> =A0 =A0 =A0 =A0 "Adding a cond_resched() to allow other threads to run i=
n the
>> non-preemptive
>> =A0 =A0 case."
>>
>
> IOW, my question is "why only this cond_resched() should be fixed ?"

cond_resched() forces this thread to be scheduled. I'm just trying
pointing out the use of cond_resched(), until unless I'm not missing
anything.

> What's bad with all cond_resched() in the kernel as no-op in CONFIG_PREEM=
PT ?
>
cond_resched() basically checks whether it needs to be scheduled or
not. But, we know in advance that we don't need cond_resched in
CONFIG_PREEMPT.

Thanks,
Rakib

> Thanks,
> -Kame
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
