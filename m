Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 465B56B002D
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 16:31:02 -0500 (EST)
Received: by vbbfq11 with SMTP id fq11so3917927vbb.14
        for <linux-mm@kvack.org>; Mon, 21 Nov 2011 13:30:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1321907275.13860.12.camel@pasglop>
References: <20111121131531.GA1679@x4.trippels.de>
	<1321884966.10470.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20111121153621.GA1678@x4.trippels.de>
	<1321890510.10470.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20111121161036.GA1679@x4.trippels.de>
	<1321894353.10470.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1321895706.10470.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20111121173556.GA1673@x4.trippels.de>
	<1321900743.10470.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20111121185215.GA1673@x4.trippels.de>
	<20111121195113.GA1678@x4.trippels.de>
	<1321907275.13860.12.camel@pasglop>
Date: Mon, 21 Nov 2011 23:30:59 +0200
Message-ID: <CAOJsxLGLZ23momLxidvhC+2LCtmnwmPMS2ASdke8V8gGFGa=AA@mail.gmail.com>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Markus Trippelsdorf <markus@trippelsdorf.de>, Eric Dumazet <eric.dumazet@gmail.com>, "Alex,Shi" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Christian Kujau <lists@nerdbynature.de>

On Mon, 2011-11-21 at 20:51 +0100, Markus Trippelsdorf wrote:
>> On 2011.11.21 at 19:52 +0100, Markus Trippelsdorf wrote:
>> > On 2011.11.21 at 19:39 +0100, Eric Dumazet wrote:
>> > > Le lundi 21 novembre 2011 =E0 18:35 +0100, Markus Trippelsdorf a =E9=
crit :
>> > >
>> > > > New one:
>> > >
>> > > ...
>> > >
>> > > I was just wondering if you were using CONFIG_CGROUPS=3Dy, and if ye=
s, if
>> > > you could try to disable it.
>> >
>> > # CONFIG_CGROUPS is not set
>> >
>> > (I never enable CGROUPS on my machines)
>>
>> Just for the record, I've attached full dmesg and my .config.
>> (Will continue testing tomorrow)

On Mon, Nov 21, 2011 at 10:27 PM, Benjamin Herrenschmidt
<benh@kernel.crashing.org> wrote:
> Note that I hit a similar looking crash (sorry, I couldn't capture a
> backtrace back then) on a PowerMac G5 (ppc64) while doing a large rsync
> transfer yesterday with -rc2-something (cfcfc9ec) and
> Christian Kujau (CC) seems to be able to reproduce something similar on
> some other ppc platform (Christian, what is your setup ?)
>
> We haven't hit the poison checks, more like bad pointer derefs, almost
> always in SLUB coming from skb alloc or free.
>
> In my case, it's not easy to reproduce, so a bisection would be
> error-prone.

Does CONFIG_SLAB make all the issues go away or are you still able to
reproduce corruption with it? I'm asking because we have the per-cpu
partial list patches in 3.2-rc1 and I'd like to rule them out as a
suspect.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
