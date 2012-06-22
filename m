Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id E2F056B0279
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 19:12:43 -0400 (EDT)
Received: by yhjj52 with SMTP id j52so2615263yhj.8
        for <linux-mm@kvack.org>; Fri, 22 Jun 2012 16:12:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1206221609220.15114@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1206221444370.23486@chino.kir.corp.google.com>
 <CAHGf_=p4SS7qA_eRpBF0PawyUa8DpYncL0LS-=B4tHFaDUKV-w@mail.gmail.com> <alpine.DEB.2.00.1206221609220.15114@chino.kir.corp.google.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 22 Jun 2012 19:12:21 -0400
Message-ID: <CAHGf_=q=6uWb4wpZxnZNGY=VohoaWrDJtiQk0Rn59unNSMTnyQ@mail.gmail.com>
Subject: Re: [patch] mm, oom: replace some information in tasklist dump
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_info("[%5d] %5d %5d %8lu %8lu %3u =A0=
 =A0 %3d =A0 =A0 =A0 =A0 %5d %s\n",
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_info("[%5d] %5d %5d %8lu %8lu %7lu %8=
lu =A0 =A0 =A0 =A0 %5d %s\n",
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0task->pid, from_kuid(&i=
nit_user_ns, task_uid(task)),
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0task->tgid, task->mm->t=
otal_vm, get_mm_rss(task->mm),
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 task_cpu(task), task->si=
gnal->oom_adj,
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 task->mm->nr_ptes,
>>
>> nr_ptes should be folded into rss. it's "resident".
>> btw, /proc rss info should be fixed too.
>
> If we can fold rss into get_mm_rss() and every caller is ok with that,
> then we can remove showing it here and adding it explicitly in
> oom_badness().

No worth to make fragile ABI. Do you have any benefit?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
