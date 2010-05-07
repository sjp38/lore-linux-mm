Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 928EA6200B0
	for <linux-mm@kvack.org>; Fri,  7 May 2010 01:15:25 -0400 (EDT)
Received: by fg-out-1718.google.com with SMTP id 22so466702fge.8
        for <linux-mm@kvack.org>; Thu, 06 May 2010 22:15:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100507100729.a6589d8a.kamezawa.hiroyu@jp.fujitsu.com>
References: <1273058509-16625-1-git-send-email-ext-phil.2.carmody@nokia.com>
	 <1273058509-16625-2-git-send-email-ext-phil.2.carmody@nokia.com>
	 <20100506142417.6d317068.akpm@linux-foundation.org>
	 <20100507100729.a6589d8a.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 7 May 2010 08:15:22 +0300
Message-ID: <t2ucc557aab1005062215p41f6086p21a19710d528d034@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: memcontrol - uninitialised return value
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Phil Carmody <ext-phil.2.carmody@nokia.com>, balbir@linux.vnet.ibm.com, nishimura@mxp.nes.nec.co.jp, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Paul Menage <menage@google.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, May 7, 2010 at 4:07 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu, 6 May 2010 14:24:17 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
>
>> On Wed, =C2=A05 May 2010 14:21:49 +0300
>> Phil Carmody <ext-phil.2.carmody@nokia.com> wrote:
>>
>> > From: Phil Carmody <ext-phil.2.carmody@nokia.com>
>> >
>> > Only an out of memory error will cause ret to be set.
>> >
>> > Acked-by: Kirill A. Shutemov <kirill@shutemov.name>
>> > Signed-off-by: Phil Carmody <ext-phil.2.carmody@nokia.com>
>> > ---
>> > =C2=A0mm/memcontrol.c | =C2=A0 =C2=A02 +-
>> > =C2=A01 files changed, 1 insertions(+), 1 deletions(-)
>> >
>> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> > index 90e32b2..09af773 100644
>> > --- a/mm/memcontrol.c
>> > +++ b/mm/memcontrol.c
>> > @@ -3464,7 +3464,7 @@ static int mem_cgroup_unregister_event(struct cg=
roup *cgrp, struct cftype *cft,
>> > =C2=A0 =C2=A0 int type =3D MEMFILE_TYPE(cft->private);
>> > =C2=A0 =C2=A0 u64 usage;
>> > =C2=A0 =C2=A0 int size =3D 0;
>> > - =C2=A0 int i, j, ret;
>> > + =C2=A0 int i, j, ret =3D 0;
>> >
>> > =C2=A0 =C2=A0 mutex_lock(&memcg->thresholds_lock);
>> > =C2=A0 =C2=A0 if (type =3D=3D _MEM)
>>
>> afacit the return value of cftype.unregister_event() is always ignored
>> anyway. =C2=A0Perhaps it should be changed to void-returning, or fixed.
>>
>>
> Ah, it's now "TODO". But hmm...."unregister_event()" is called by workque=
ue.
> (for avoiding race?)

Because it can be called from atomic context.

> I think unregister_event should be "void" and mem_cgroup_unregister_event=
()
> should be implemented as "never fail" function.
>
> I'll try by myself....but if someone knows this event notifier implementa=
tion well,
> please.

Ok, better if I'll do it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
