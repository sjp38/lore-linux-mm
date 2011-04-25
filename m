Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 376EA8D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 13:16:45 -0400 (EDT)
Received: from mail-ey0-f169.google.com (mail-ey0-f169.google.com [209.85.215.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p3PHFu9t032484
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 10:15:57 -0700
Received: by eyd9 with SMTP id 9so1092695eyd.14
        for <linux-mm@kvack.org>; Mon, 25 Apr 2011 10:15:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110425190032.7904c95d@neptune.home>
References: <20110424202158.45578f31@neptune.home> <20110424235928.71af51e0@neptune.home>
 <20110425114429.266A.A69D9226@jp.fujitsu.com> <BANLkTinVQtLbmBknBZeY=7w7AOyQk61Pew@mail.gmail.com>
 <20110425111705.786ef0c5@neptune.home> <BANLkTi=d0UHrYXyTK0CBZYCSK-ax8+wuWQ@mail.gmail.com>
 <20110425180450.1ede0845@neptune.home> <BANLkTikSLA59tdgRL4B=cr5tvP2NbzZ=KA@mail.gmail.com>
 <20110425190032.7904c95d@neptune.home>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 25 Apr 2011 10:10:28 -0700
Message-ID: <BANLkTi=hQ=HcPLCdbb1pSi+xJByMTah-gw@mail.gmail.com>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning, regression?
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?Q?Bruno_Pr=E9mont?= <bonbons@linux-vserver.org>
Cc: Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

On Mon, Apr 25, 2011 at 10:00 AM, Bruno Pr=E9mont
<bonbons@linux-vserver.org> wrote:
>
> I hope tiny-rcu is not that broken... as it would mean driving any
> PREEMPT_NONE or PREEMPT_VOLUNTARY system out of memory when compiling
> packages (and probably also just unpacking larger tarballs or running
> things like du).

I'm sure that TINYRCU can be fixed if it really is the problem.

So I just want to make sure that we know what the root cause of your
problem is. It's quite possible that it _is_ a real leak of filp or
something, but before possibly wasting time trying to figure that out,
let's see if your config is to blame.

> And with system doing nothing (except monitoring itself) memory usage
> goes increasing all the time until it starves (well it seems to keep
> ~20M free, pushing processes it can to swap). Config is just being
> make oldconfig from working 2.6.38 kernel (answering default for new
> options)

How sure are you that the system really is idle? Quite frankly, the
constant growing doesn't really look idle to me.

> Attached graph matching numbers of previous mail. (dropping caches was at
> 17:55, system idle since then)

Nothing at all going on in 'ps' during that time? And what does
slabinfo say at that point now that kmemleak isn't dominating
everything else?

                        Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
