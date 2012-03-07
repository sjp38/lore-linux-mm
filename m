Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 20C2A6B0083
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 00:30:31 -0500 (EST)
Received: by yhr47 with SMTP id 47so3359986yhr.14
        for <linux-mm@kvack.org>; Tue, 06 Mar 2012 21:30:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1203062025490.24600@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1203041341340.9534@chino.kir.corp.google.com>
 <20120306160833.0e9bf50a.akpm@linux-foundation.org> <alpine.DEB.2.00.1203061950050.24600@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1203062025490.24600@chino.kir.corp.google.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Wed, 7 Mar 2012 00:30:10 -0500
Message-ID: <CAHGf_=qG1Lah00fGTNENvtgacsUt1=FcMKyt+kmPG1=UD6ecNw@mail.gmail.com>
Subject: Re: [patch] mm, mempolicy: make mempolicies robust against errors
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

2012/3/6 David Rientjes <rientjes@google.com>:
> It's unnecessary to BUG() in situations when a mempolicy has an
> unsupported mode, it just means that a mode doesn't have complete coverag=
e
> in all mempolicy functions -- which is an error, but not a fatal error --
> or that a bit has flipped. =A0Regardless, it's sufficient to warn the use=
r
> in the kernel log of the situation once and then proceed without crashing
> the system.
>
> This patch converts nearly all the BUG()'s in mm/mempolicy.c to
> WARN_ON_ONCE(1) and provides the necessary code to return successfully.

I'm sorry. I simple don't understand the purpose of this patch. every
mem policy  syscalls have input check then we can't hit BUG()s in
mempolicy.c. To me, BUG() is obvious notation than WARN_ON_ONCE().

We usually use WARN_ON_ONCE() for hw drivers code. Because of, the
warn-on mean "we believe this route never reach, but we afraid there
is crazy buggy hardware".

And, now BUG() has renreachable() annotation. why don't it work?


#define BUG()                                                   \
do {                                                            \
        asm volatile("ud2");                                    \
        unreachable();                                          \
} while (0)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
