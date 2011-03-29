Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9D93B8D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 20:32:18 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id DDA183EE0C5
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 09:32:14 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C2C5045DE69
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 09:32:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F80345DE4E
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 09:32:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 902AD1DB802C
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 09:32:14 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4DDA81DB803C
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 09:32:14 +0900 (JST)
Date: Tue, 29 Mar 2011 09:25:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/4] forkbomb killer
Message-Id: <20110329092542.190fa31d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTi=BJrqsTTAuxz-ZDeioCZ=Sc6hbSw@mail.gmail.com>
References: <20110324182240.5fe56de2.kamezawa.hiroyu@jp.fujitsu.com>
	<20110324105222.GA2625@barrios-desktop>
	<20110325090411.56c5e5b2.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTi=f3gu7-8uNiT4qz6s=BOhto5s=7g@mail.gmail.com>
	<20110325115453.82a9736d.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTim3fFe3VzvaWRwzaCT6aRd-yeyfiQ@mail.gmail.com>
	<20110326023452.GA8140@google.com>
	<AANLkTi=ng9vwoMJ=tseWwTsXMf9XZkMKUexcpEmQ45M_@mail.gmail.com>
	<BANLkTi=BJrqsTTAuxz-ZDeioCZ=Sc6hbSw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "rientjes@google.com" <rientjes@google.com>, Andrey Vagin <avagin@openvz.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>

On Mon, 28 Mar 2011 16:46:42 -0700
Michel Lespinasse <walken@google.com> wrote:

> On Sat, Mar 26, 2011 at 1:48 AM, Hiroyuki Kamezawa
> <kamezawa.hiroyuki@gmail.com> wrote:
> > 2011/3/26 Michel Lespinasse <walken@google.com>:
> >> I haven't heard of fork bombs being an issue for us (and it's not been
> >> for me on my desktop, either).
> >>
> >> Also, I want to point out that there is a classical userspace solution
> >> for this, as implemented by killall5 for example. One can do
> >> kill(-1, SIGSTOP) to stop all processes that they can send
> >> signals to (except for init and itself). Target processes
> >> can never catch or ignore the SIGSTOP. This stops the fork bomb
> >> from causing further damage. Then, one can look at the process
> >> tree and do whatever is appropriate - including killing by uid,
> >> by cgroup or whatever policies one wants to implement in userspace.
> >> Finally, the remaining processes can be restarted using SIGCONT.
> >>
> >
> > Can that solution work even under OOM situation without new login/commands ?
> > Please show us your solution, how to avoid Andrey's Bomb A with your way.
> > Then, we can add Documentation, at least. Or you can show us your tool.
> 
> To be clear, I don't have a full solution. I just think that the
> problem is approachable from userspace by freezing processes and then
> sorting them out. The killall5 utility is an example of that, though
> you would possibly want to add more smarts to it. If we want to
> include a kernel solution, I do like the simplicity of Minchan's
> proposal, too. But, I don't have a strong opinion on this matter, so
> feel free to ignore me if this is not useful feedback.
> 

I don't have strong opinion, too. I just think easily breakable kernel
by an user application is not ideal thing for me. To go to other buildings
to press reset-button is good for my health. I just implemnted a solution and
it seems to work well. Then, just want to ask how my patch looks.

But no one see patches, and it seems this feature is not welcome.
I'll continue to walk or just use virtual machines for testing OOM.

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
