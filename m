Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3CEB16B016A
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 22:38:56 -0400 (EDT)
Received: by wwg9 with SMTP id 9so5859621wwg.26
        for <linux-mm@kvack.org>; Tue, 06 Sep 2011 19:38:53 -0700 (PDT)
Subject: Re: [PATCH] per-cgroup tcp buffer limitation
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <CAHH2K0YJA7vZZ3QNAf63TZOnWhsRUwfuZYfntBL4muZ0G_Vt2w@mail.gmail.com>
References: <1315276556-10970-1-git-send-email-glommer@parallels.com>
	 <CAHH2K0aJxjinSu0Ek6jzsZ5dBmm5mEU-typuwYWYWEudF2F3Qg@mail.gmail.com>
	 <4E664766.40200@parallels.com>
	 <CAHH2K0YJA7vZZ3QNAf63TZOnWhsRUwfuZYfntBL4muZ0G_Vt2w@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 07 Sep 2011 04:38:40 +0200
Message-ID: <1315363120.3400.54.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Glauber Costa <glommer@parallels.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, netdev@vger.kernel.org, xemul@parallels.com, "David S. Miller" <davem@davemloft.net>, Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>, "Eric W. Biederman" <ebiederm@xmission.com>

Le mardi 06 septembre 2011 A  15:12 -0700, Greg Thelen a A(C)crit :

> >>> +#define sk_sockets_allocated(sk)                               \
> >>> +({                                                             \
> >>> +       struct percpu_counter *__p;                             \
> >>> +       __p = (sk)->sk_prot->sockets_allocated(sk->sk_cgrp);    \
> >>> +       __p;                                                    \
> >>> +})
> 
> Could this be simplified as (same applies to following few macros):
> 
> static inline struct percpu_counter *sk_sockets_allocated(struct sock *sk)
> {
>         return sk->sk_prot->sockets_allocated(sk->sk_cgrp);
> }
> 

Please Greg, dont copy/paste huge sequence of code if you dont have
anymore comments.

Right before sending your mail, remove all parts that we already got in
previous mails.

Thanks


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
