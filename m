Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 4F8086B005A
	for <linux-mm@kvack.org>; Thu,  6 Aug 2009 01:16:47 -0400 (EDT)
Received: by gxk3 with SMTP id 3so768073gxk.14
        for <linux-mm@kvack.org>; Wed, 05 Aug 2009 22:16:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090806013444.GA22095@redhat.com>
References: <20090804191031.6A3D.A69D9226@jp.fujitsu.com>
	 <20090804192514.6A40.A69D9226@jp.fujitsu.com>
	 <20090806013444.GA22095@redhat.com>
Date: Thu, 6 Aug 2009 14:16:51 +0900
Message-ID: <2f11576a0908052216i560b977by68c400020e786d47@mail.gmail.com>
Subject: Re: [PATCH 1/4] oom: move oom_adj to signal_struct
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

2009/8/6 Oleg Nesterov <oleg@redhat.com>:
> Sorry for late reply. And sorry, I didn't read these patches carefully ye=
t,
> probably missed something...
>
> On 08/04, KOSAKI Motohiro wrote:
>>
>> --- a/mm/oom_kill.c
>> +++ b/mm/oom_kill.c
>> @@ -34,6 +34,31 @@ int sysctl_oom_dump_tasks;
>> =A0static DEFINE_SPINLOCK(zone_scan_lock);
>> =A0/* #define DEBUG */
>>
>> +int get_oom_adj(struct task_struct *tsk)
>
> is it used outside oom_kill.c ?

Good catch.
Will fix.


>> +{
>> + =A0 =A0 unsigned long flags;
>> + =A0 =A0 int oom_adj =3D OOM_DISABLE;
>> +
>> + =A0 =A0 if (tsk->mm && lock_task_sighand(tsk, &flags)) {
>
> Minor nit. _Afaics_, unlike proc, oom_kill.c never needs lock_task_sighan=
d()
> to access ->signal->oom_adj.
>
> If the task was found under tasklist_lock by for_each_process/do_each_thr=
ead
> it must have the valid ->signal !=3D NULL and it can't go away.

Thanks good suggestion!
Will fix.



> With these patches I think mm-introduce-proc-pid-oom_adj_child.patch shou=
ld
> be dropped. This is good ;)

I agree, It should be dropped.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
