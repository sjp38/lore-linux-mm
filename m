Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 98A6E6001DA
	for <linux-mm@kvack.org>; Tue,  9 Feb 2010 05:18:39 -0500 (EST)
Received: by pzk4 with SMTP id 4so120464pzk.1
        for <linux-mm@kvack.org>; Tue, 09 Feb 2010 02:18:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1002090150390.16525@chino.kir.corp.google.com>
References: <20100205093932.1dcdeb5f.kamezawa.hiroyu@jp.fujitsu.com>
	 <28c262361002050830m7519f1c3y8860540708527fc0@mail.gmail.com>
	 <20100209093246.36c50bae.kamezawa.hiroyu@jp.fujitsu.com>
	 <28c262361002081724l1b64e316v3141fb4567dbf905@mail.gmail.com>
	 <alpine.DEB.2.00.1002082242180.19744@chino.kir.corp.google.com>
	 <28c262361002090140p37fac1e4q2652e7a4ee3a84d4@mail.gmail.com>
	 <alpine.DEB.2.00.1002090150390.16525@chino.kir.corp.google.com>
Date: Tue, 9 Feb 2010 19:18:38 +0900
Message-ID: <28c262361002090218w62bb49bcp5151f1e8b61af801@mail.gmail.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix oom killer kills a task in other
	cgroup
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 9, 2010 at 6:55 PM, David Rientjes <rientjes@google.com> wrote:
> On Tue, 9 Feb 2010, Minchan Kim wrote:
>
>> My point was following as.
>> We try to kill child of OOMed task at first.
>> But we can't know any locked state of child when OOM happens.
>
> We don't need to, child->alloc_lock can be contended in which case we'll
> just spin but it won't stay locked because we're out of memory. =C2=A0In =
other
> words, nothing takes task_lock(child) and then waits for memory to become
> available while holding it, that would be fundamentally broken. =C2=A0So =
there
> is a dependency here and that is that task_lock(current) can't be taken i=
n
> the page allocator because we'll deadlock in the oom killer, but that
> isn't anything new.

I understand it so I don't oppose Kame's original patch from now on. :)
Thanks for kind explanation. David.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
