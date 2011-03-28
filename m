Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 87B558D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 19:46:49 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p2SNklwE008952
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 16:46:47 -0700
Received: from gyf3 (gyf3.prod.google.com [10.243.50.67])
	by hpaq1.eem.corp.google.com with ESMTP id p2SNkhaZ022316
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 16:46:45 -0700
Received: by gyf3 with SMTP id 3so1575201gyf.31
        for <linux-mm@kvack.org>; Mon, 28 Mar 2011 16:46:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTi=ng9vwoMJ=tseWwTsXMf9XZkMKUexcpEmQ45M_@mail.gmail.com>
References: <20110324182240.5fe56de2.kamezawa.hiroyu@jp.fujitsu.com>
	<20110324105222.GA2625@barrios-desktop>
	<20110325090411.56c5e5b2.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTi=f3gu7-8uNiT4qz6s=BOhto5s=7g@mail.gmail.com>
	<20110325115453.82a9736d.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTim3fFe3VzvaWRwzaCT6aRd-yeyfiQ@mail.gmail.com>
	<20110326023452.GA8140@google.com>
	<AANLkTi=ng9vwoMJ=tseWwTsXMf9XZkMKUexcpEmQ45M_@mail.gmail.com>
Date: Mon, 28 Mar 2011 16:46:42 -0700
Message-ID: <BANLkTi=BJrqsTTAuxz-ZDeioCZ=Sc6hbSw@mail.gmail.com>
Subject: Re: [PATCH 0/4] forkbomb killer
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "rientjes@google.com" <rientjes@google.com>, Andrey Vagin <avagin@openvz.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>

On Sat, Mar 26, 2011 at 1:48 AM, Hiroyuki Kamezawa
<kamezawa.hiroyuki@gmail.com> wrote:
> 2011/3/26 Michel Lespinasse <walken@google.com>:
>> I haven't heard of fork bombs being an issue for us (and it's not been
>> for me on my desktop, either).
>>
>> Also, I want to point out that there is a classical userspace solution
>> for this, as implemented by killall5 for example. One can do
>> kill(-1, SIGSTOP) to stop all processes that they can send
>> signals to (except for init and itself). Target processes
>> can never catch or ignore the SIGSTOP. This stops the fork bomb
>> from causing further damage. Then, one can look at the process
>> tree and do whatever is appropriate - including killing by uid,
>> by cgroup or whatever policies one wants to implement in userspace.
>> Finally, the remaining processes can be restarted using SIGCONT.
>>
>
> Can that solution work even under OOM situation without new login/command=
s ?
> Please show us your solution, how to avoid Andrey's Bomb =A0with your way=
.
> Then, we can add Documentation, at least. Or you can show us your tool.

To be clear, I don't have a full solution. I just think that the
problem is approachable from userspace by freezing processes and then
sorting them out. The killall5 utility is an example of that, though
you would possibly want to add more smarts to it. If we want to
include a kernel solution, I do like the simplicity of Minchan's
proposal, too. But, I don't have a strong opinion on this matter, so
feel free to ignore me if this is not useful feedback.

--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
