Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2442C8D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 17:31:11 -0400 (EDT)
Received: from mail-ew0-f41.google.com (mail-ew0-f41.google.com [209.85.215.41])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p3PLUMIs028497
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 14:30:24 -0700
Received: by ewy9 with SMTP id 9so10599ewy.14
        for <linux-mm@kvack.org>; Mon, 25 Apr 2011 14:30:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110425231016.34b4293e@neptune.home>
References: <20110424235928.71af51e0@neptune.home> <20110425114429.266A.A69D9226@jp.fujitsu.com>
 <BANLkTinVQtLbmBknBZeY=7w7AOyQk61Pew@mail.gmail.com> <20110425111705.786ef0c5@neptune.home>
 <BANLkTi=d0UHrYXyTK0CBZYCSK-ax8+wuWQ@mail.gmail.com> <20110425180450.1ede0845@neptune.home>
 <BANLkTikSLA59tdgRL4B=cr5tvP2NbzZ=KA@mail.gmail.com> <20110425190032.7904c95d@neptune.home>
 <BANLkTi=hQ=HcPLCdbb1pSi+xJByMTah-gw@mail.gmail.com> <20110425203606.4e78246c@neptune.home>
 <20110425191607.GL2468@linux.vnet.ibm.com> <20110425231016.34b4293e@neptune.home>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 25 Apr 2011 14:30:02 -0700
Message-ID: <BANLkTin7wSGi1=E2c2u6Jb5TG_KUpYh=Dw@mail.gmail.com>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning, regression?
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?Q?Bruno_Pr=E9mont?= <bonbons@linux-vserver.org>
Cc: paulmck@linux.vnet.ibm.com, Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

2011/4/25 Bruno Pr=E9mont <bonbons@linux-vserver.org>:
>
> Between 1-slabinfo and 2-slabinfo some values increased (a lot) while a f=
ew
> ones did decrease. Don't know which ones are RCU-affected and which ones =
are
> not.

It really sounds as if the tiny-rcu kthread somehow just stops
handling callbacks. The ones that keep increasing do seem to be all
rcu-free'd (but I didn't really check).

The thing is shown as running:

root         6  0.0  0.0      0     0 ?        R    22:14   0:00  \_
[rcu_kthread]

but nothing seems to happen and the CPU time hasn't increased at all.

I dunno. Makes no  sense to me, but yeah, I'm definitely blaming
tiny-rcu. Paul, any ideas?

                          Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
