Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 40A726B0387
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 15:28:55 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id x64so3828502ota.1
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 12:28:55 -0800 (PST)
Received: from mail-ot0-x22d.google.com (mail-ot0-x22d.google.com. [2607:f8b0:4003:c0f::22d])
        by mx.google.com with ESMTPS id r188si2168136oib.142.2017.02.23.12.28.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Feb 2017 12:28:54 -0800 (PST)
Received: by mail-ot0-x22d.google.com with SMTP id j38so1646883otb.3
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 12:28:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CANcMJZBNe10dtK8ANtLSWS3UXeePhndN=S5otADhQdfQKOAhOw@mail.gmail.com>
References: <20170222120121.12601-1-mhocko@kernel.org> <CANcMJZBNe10dtK8ANtLSWS3UXeePhndN=S5otADhQdfQKOAhOw@mail.gmail.com>
From: Todd Kjos <tkjos@google.com>
Date: Thu, 23 Feb 2017 12:28:53 -0800
Message-ID: <CAHRSSEzvcmc3JMc=CnzBeUVWy2t=DD2WgnysmaHP1fp9B80Aug@mail.gmail.com>
Subject: Re: [PATCH] staging, android: remove lowmemory killer from the tree
Content-Type: multipart/alternative; boundary=94eb2c19083a3ec86305493876a3
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: Michal Hocko <mhocko@kernel.org>, Greg KH <gregkh@linuxfoundation.org>, =?UTF-8?B?QXJ2ZSBIasO4bm5ldsOlZw==?= <arve@android.com>, Riley Andrews <riandrews@android.com>, devel@driverdev.osuosl.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.com>, Android Kernel Team <kernel-team@android.com>, Martijn Coenen <maco@google.com>, Rom Lemarchand <romlem@google.com>, Tim Murray <timmurray@google.com>

--94eb2c19083a3ec86305493876a3
Content-Type: text/plain; charset=UTF-8

+timmurray

On Thu, Feb 23, 2017 at 12:24 PM, John Stultz <john.stultz@linaro.org>
wrote:

> On Wed, Feb 22, 2017 at 4:01 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > From: Michal Hocko <mhocko@suse.com>
> >
> > Lowmemory killer is sitting in the staging tree since 2008 without any
> > serious interest for fixing issues brought up by the MM folks. The main
> > objection is that the implementation is basically broken by design:
> >         - it hooks into slab shrinker API which is not suitable for this
> >           purpose. lowmem_count implementation just shows this nicely.
> >           There is no scaling based on the memory pressure and no
> >           feedback to the generic shrinker infrastructure.
> >           Moreover lowmem_scan is called way too often for the heavy
> >           work it performs.
> >         - it is not reclaim context aware - no NUMA and/or memcg
> >           awareness.
> >
> > As the code stands right now it just adds a maintenance overhead when
> > core MM changes have to update lowmemorykiller.c as well. It also seems
> > that the alternative LMK implementation will be solely in the userspace
> > so this code has no perspective it seems. The staging tree is supposed
> > to be for a code which needs to be put in shape before it can be merged
> > which is not the case here obviously.
>
> So, just for context, Android does have a userland LMK daemon (using
> the mempressure notifiers) as you mentioned, but unfortunately I'm
> unaware of any devices that ship with that implementation.
>
> This is reportedly because while the mempressure notifiers provide a
> the signal to userspace, the work the deamon then has to do to look up
> per process memory usage, in order to figure out who is best to kill
> at that point was too costly and resulted in poor device performance.
>
> So for shipping Android devices, the LMK is still needed. However, its
> not critical for basic android development, as the system will
> function without it. Additionally I believe most vendors heavily
> customize the LMK in their vendor tree, so the value of having it in
> staging might be relatively low.
>
> It would be great however to get a discussion going here on what the
> ulmkd needs from the kernel in order to efficiently determine who best
> to kill, and how we might best implement that.
>
> thanks
> -john
>

--94eb2c19083a3ec86305493876a3
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">+timmurray</div><div class=3D"gmail_extra"><br><div class=
=3D"gmail_quote">On Thu, Feb 23, 2017 at 12:24 PM, John Stultz <span dir=3D=
"ltr">&lt;<a href=3D"mailto:john.stultz@linaro.org" target=3D"_blank">john.=
stultz@linaro.org</a>&gt;</span> wrote:<br><blockquote class=3D"gmail_quote=
" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">O=
n Wed, Feb 22, 2017 at 4:01 AM, Michal Hocko &lt;<a href=3D"mailto:mhocko@k=
ernel.org">mhocko@kernel.org</a>&gt; wrote:<br>
&gt; From: Michal Hocko &lt;<a href=3D"mailto:mhocko@suse.com">mhocko@suse.=
com</a>&gt;<br>
&gt;<br>
&gt; Lowmemory killer is sitting in the staging tree since 2008 without any=
<br>
&gt; serious interest for fixing issues brought up by the MM folks. The mai=
n<br>
&gt; objection is that the implementation is basically broken by design:<br=
>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0- it hooks into slab shrinker API whi=
ch is not suitable for this<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0purpose. lowmem_count implemen=
tation just shows this nicely.<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0There is no scaling based on t=
he memory pressure and no<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0feedback to the generic shrink=
er infrastructure.<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Moreover lowmem_scan is called=
 way too often for the heavy<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0work it performs.<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0- it is not reclaim context aware - n=
o NUMA and/or memcg<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0awareness.<br>
&gt;<br>
&gt; As the code stands right now it just adds a maintenance overhead when<=
br>
&gt; core MM changes have to update lowmemorykiller.c as well. It also seem=
s<br>
&gt; that the alternative LMK implementation will be solely in the userspac=
e<br>
&gt; so this code has no perspective it seems. The staging tree is supposed=
<br>
&gt; to be for a code which needs to be put in shape before it can be merge=
d<br>
&gt; which is not the case here obviously.<br>
<br>
So, just for context, Android does have a userland LMK daemon (using<br>
the mempressure notifiers) as you mentioned, but unfortunately I&#39;m<br>
unaware of any devices that ship with that implementation.<br>
<br>
This is reportedly because while the mempressure notifiers provide a<br>
the signal to userspace, the work the deamon then has to do to look up<br>
per process memory usage, in order to figure out who is best to kill<br>
at that point was too costly and resulted in poor device performance.<br>
<br>
So for shipping Android devices, the LMK is still needed. However, its<br>
not critical for basic android development, as the system will<br>
function without it. Additionally I believe most vendors heavily<br>
customize the LMK in their vendor tree, so the value of having it in<br>
staging might be relatively low.<br>
<br>
It would be great however to get a discussion going here on what the<br>
ulmkd needs from the kernel in order to efficiently determine who best<br>
to kill, and how we might best implement that.<br>
<br>
thanks<br>
<span class=3D"HOEnZb"><font color=3D"#888888">-john<br>
</font></span></blockquote></div><br></div>

--94eb2c19083a3ec86305493876a3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
