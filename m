Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 0C6706B004D
	for <linux-mm@kvack.org>; Tue,  8 May 2012 05:16:01 -0400 (EDT)
From: <leonid.moiseichuk@nokia.com>
Subject: RE: [PATCH 3/3] vmevent: Implement special low-memory attribute
Date: Tue, 8 May 2012 09:15:46 +0000
Message-ID: <84FF21A720B0874AA94B46D76DB98269045D63B3@008-AM1MPN1-003.mgdnok.nokia.com>
References: <20120501132409.GA22894@lizard>	<20120501132620.GC24226@lizard>
	<4FA35A85.4070804@kernel.org>	<20120504073810.GA25175@lizard>
	<CAOJsxLH_7mMMe+2DvUxBW1i5nbUfkbfRE3iEhLQV9F_MM7=eiw@mail.gmail.com>
	<CAHGf_=qcGfuG1g15SdE0SDxiuhCyVN025pQB+sQNuNba4Q4jcA@mail.gmail.com>
	<20120507121527.GA19526@lizard>	<4FA82056.2070706@gmail.com>
	<CAOJsxLHQcDZSHJZg+zbptqmT9YY0VTkPd+gG_zgMzs+HaV_cyA@mail.gmail.com>
	<CAHGf_=q1nbu=3cnfJ4qXwmngMPB-539kg-DFN2FJGig8+dRaNw@mail.gmail.com>
	<CAOJsxLFAavdDbiLnYRwe+QiuEHSD62+Sz6LJTk+c3J9gnLVQ_w@mail.gmail.com>
	<CAHGf_=pSLfAue6AR5gi5RQ7xvgTxpZckA=Ja1fO1AkoO1o_DeA@mail.gmail.com>
	<CAOJsxLG1+zhOKgi2Rg1eSoXSCU8QGvHVED_EefOOLP-6JbMDkg@mail.gmail.com>
	<4FA8D046.7000808@gmail.com>
 <CAOJsxLGWtJy7q6ij_-tN8nVTr-OXpgdWVkXsOda8S9mJzo7n2w@mail.gmail.com>
In-Reply-To: <CAOJsxLGWtJy7q6ij_-tN8nVTr-OXpgdWVkXsOda8S9mJzo7n2w@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: penberg@kernel.org, kosaki.motohiro@gmail.com
Cc: anton.vorontsov@linaro.org, minchan@kernel.org, john.stultz@linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

> -----Original Message-----
> From: penberg@gmail.com [mailto:penberg@gmail.com] On Behalf Of ext
> Pekka Enberg
> Sent: 08 May, 2012 11:03
> To: KOSAKI Motohiro
> Cc: Anton Vorontsov; Minchan Kim; Moiseichuk Leonid (Nokia-MP/Espoo); Joh=
n
...
> >> That comes from a real-world requirement. See Leonid's email on the to=
pic:
> >>
> >> https://lkml.org/lkml/2012/5/2/42
> >
> > I know, many embedded guys prefer such timer interval. I also have an
> > experience similar logic when I was TV box developer. but I must
> > disagree. Someone hope timer housekeeping complexity into kernel. but
> > I haven't seen any justification.
>=20
> Leonid?

The "usleep(timeout); read(vmevent_fd)" will eliminate opportunity to use v=
mevent API for mobile devices. =20
Developers already have to use heartbeat primitives to align/sync timers an=
d update code which is not always simple to do.
But the idea is to have user-space wakeup only if we have something change =
in memory numbers, thus aligned timers will not help much in vmevent case d=
ue to memory situation may change a lot in short time.
Short depends from software stack but usually it below 1s.  To have use-tim=
e and wakeups on good level (below 50Hz by e.g. powertop) and allow cpu swi=
tch off timers of such short period like 1s are not allowed.

Leonid
PS: Sorry, meetings prevent to do interesting things :(  I am tracking conv=
ersation with quite low understanding how it will be useful for practical n=
eeds because user-space developers in 80% cases needs to track simply dirty=
 memory changes i.e. modified pages which cannot be dropped.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
