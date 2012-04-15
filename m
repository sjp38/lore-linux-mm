Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id 4FAF56B004A
	for <linux-mm@kvack.org>; Sun, 15 Apr 2012 07:47:10 -0400 (EDT)
References: <1334483226.20721.YahooMailNeo@web162003.mail.bf1.yahoo.com> <CAFLxGvwJCMoiXFn3OgwiX+B50FTzGZmo6eG3xQ1KaPsEVZVA1g@mail.gmail.com>
Message-ID: <1334490429.67558.YahooMailNeo@web162006.mail.bf1.yahoo.com>
Date: Sun, 15 Apr 2012 04:47:09 -0700 (PDT)
From: PINTU KUMAR <pintu_agarwal@yahoo.com>
Reply-To: PINTU KUMAR <pintu_agarwal@yahoo.com>
Subject: Re: [NEW]: Introducing shrink_all_memory from user space
In-Reply-To: <CAFLxGvwJCMoiXFn3OgwiX+B50FTzGZmo6eG3xQ1KaPsEVZVA1g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: richard -rw- weinberger <richard.weinberger@gmail.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "pintu.k@samsung.com" <pintu.k@samsung.com>

=0A=0A> =0A> This is fundamentally flawed.=0A> You're assuming that only on=
e program will use this interface.=0A> Linux is a multi/user-tasking system=
=0A=0ADear Richard, Thank you for your comments.=0AI am sorry but this is m=
eant only for *root* user.=0AThat is only root user can do this: "echo 512 =
> /dev/shrinkmem"=0AIf other user try to write in it: it says permission de=
nied as follows:=0Apintu@pintu-ubuntu:~$ echo 512 > /dev/shrinkmem=0A-bash:=
 /dev/shrinkmem: Permission denied=0A=0AMoreover, this is mainly meant for =
mobile phones where there is only *one* user.=0A=0A> =0A> If we expose it t=
o user space *every* program/user will try too free=0A> memory such that it=
=0A> can use more.=0A> Can you see the problem?=0A> =0AAs indicated above, =
every program/user cannot use it, as it requires root privileges.=0AOk, you=
 mean to say, every driver can call "shrink_all_memory" simultaneously??=0A=
Well, we can implement locking for that.=0AAnyways, I wrote a simple script=
 to do this (echo 512 > /dev/shrinkmem) in a loop for 20 times from 2 diffe=
rent terminal (as root) and it works.=0AI cannot see any problem.=0ACan you=
 elaborate more please?=0A=0A=0AThanks,=0APintu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
