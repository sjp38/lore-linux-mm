Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A66E48D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:08:53 -0400 (EDT)
Received: by ywa1 with SMTP id 1so34660ywa.14
        for <linux-mm@kvack.org>; Mon, 25 Apr 2011 15:08:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110425231016.34b4293e@neptune.home>
References: <20110424235928.71af51e0@neptune.home> <20110425114429.266A.A69D9226@jp.fujitsu.com>
 <BANLkTinVQtLbmBknBZeY=7w7AOyQk61Pew@mail.gmail.com> <20110425111705.786ef0c5@neptune.home>
 <BANLkTi=d0UHrYXyTK0CBZYCSK-ax8+wuWQ@mail.gmail.com> <20110425180450.1ede0845@neptune.home>
 <BANLkTikSLA59tdgRL4B=cr5tvP2NbzZ=KA@mail.gmail.com> <20110425190032.7904c95d@neptune.home>
 <BANLkTi=hQ=HcPLCdbb1pSi+xJByMTah-gw@mail.gmail.com> <20110425203606.4e78246c@neptune.home>
 <20110425191607.GL2468@linux.vnet.ibm.com> <20110425231016.34b4293e@neptune.home>
From: Mike Frysinger <vapier.adi@gmail.com>
Date: Mon, 25 Apr 2011 18:08:32 -0400
Message-ID: <BANLkTinQwJj481vFw4X5K7cOVMWjRqx-xg@mail.gmail.com>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning, regression?
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Bruno_Pr=C3=A9mont?= <bonbons@linux-vserver.org>
Cc: paulmck@linux.vnet.ibm.com, Linus Torvalds <torvalds@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

2011/4/25 Bruno Pr=C3=A9mont:
> With + + TREE_PREMPT_RCU system was stable compiling for over 2 hours,
> switching to TINY_RCU, filp count started increasing pretty early after b=
eginning
> compiling.

since you can reproduce fairly easily, could you try some of the major
rc's to see if you could narrow down things ?  see if 2.6.39-rc[123]
all act the same while 2.6.38 works ?
-mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
