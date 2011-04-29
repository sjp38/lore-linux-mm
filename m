Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7644D900001
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 14:10:11 -0400 (EDT)
Received: by yxt33 with SMTP id 33so1723527yxt.14
        for <linux-mm@kvack.org>; Fri, 29 Apr 2011 11:10:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LFD.2.02.1104282353140.3005@ionos>
References: <20110426112756.GF4308@linux.vnet.ibm.com> <20110426183859.6ff6279b@neptune.home>
 <20110426190918.01660ccf@neptune.home> <BANLkTikjuqWP+PAsObJH4EAOyzgr2RbYNA@mail.gmail.com>
 <alpine.LFD.2.02.1104262314110.3323@ionos> <20110427081501.5ba28155@pluto.restena.lu>
 <20110427204139.1b0ea23b@neptune.home> <alpine.LFD.2.02.1104272351290.3323@ionos>
 <alpine.LFD.2.02.1104281051090.19095@ionos> <BANLkTinB5S7q88dch78i-h28jDHx5dvfQw@mail.gmail.com>
 <20110428102609.GJ2135@linux.vnet.ibm.com> <1303997401.7819.5.camel@marge.simson.net>
 <BANLkTik4+PAGHF-9KREYk8y+KDQLDAp2Mg@mail.gmail.com> <alpine.LFD.2.02.1104282044120.3005@ionos>
 <20110428222301.0b745a0a@neptune.home> <alpine.LFD.2.02.1104282227340.3005@ionos>
 <20110428224444.43107883@neptune.home> <alpine.LFD.2.02.1104282251080.3005@ionos>
 <1304027480.2971.121.camel@work-vm> <alpine.LFD.2.02.1104282353140.3005@ionos>
From: Mike Frysinger <vapier.adi@gmail.com>
Date: Fri, 29 Apr 2011 14:09:50 -0400
Message-ID: <BANLkTinr9J5OQoia-+yH3_hjU6AciAxu9A@mail.gmail.com>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning, regression?
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: john stultz <johnstul@us.ibm.com>, =?UTF-8?Q?Bruno_Pr=C3=A9mont?= <bonbons@linux-vserver.org>, sedat.dilek@gmail.com, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

On Thu, Apr 28, 2011 at 18:02, Thomas Gleixner wrote:
> -static int hrtimer_clock_to_base_table[MAX_CLOCKS];
> +static int hrtimer_clock_to_base_table[MAX_CLOCKS] =3D {
> + =C2=A0 =C2=A0 =C2=A0 [CLOCK_REALTIME] =3D HRTIMER_BASE_REALTIME,
> + =C2=A0 =C2=A0 =C2=A0 [CLOCK_MONOTONIC] =3D HRTIMER_BASE_MONOTONIC,
> + =C2=A0 =C2=A0 =C2=A0 [CLOCK_BOOTTIME] =3D HRTIMER_BASE_BOOTTIME,
> +};

this would let us constify the array too
-mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
