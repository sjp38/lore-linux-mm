Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1EE606B0003
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 17:40:50 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id o206-v6so7941454oif.10
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 14:40:50 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v2sor11243312otb.93.2018.11.13.14.40.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Nov 2018 14:40:48 -0800 (PST)
Received: from mail-ot1-f42.google.com (mail-ot1-f42.google.com. [209.85.210.42])
        by smtp.gmail.com with ESMTPSA id k7-v6sm4452194oib.44.2018.11.13.14.40.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Nov 2018 14:40:47 -0800 (PST)
Received: by mail-ot1-f42.google.com with SMTP id u3so7857139ota.5
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 14:40:47 -0800 (PST)
MIME-Version: 1.0
References: <CAG48ez0ZprqUYGZFxcrY6U3Dnwt77q1NJXzzpsn1XNkRuXVppw@mail.gmail.com>
 <d43da6ad1a3c164aa03e0f22f065591a@natalenko.name> <20181113175930.3g65rlhbaimstq7g@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
 <CAGqmi74gpvJv8=B-3pVSMrDssu-aYMxW9xM7mt1WNQjGLjMZqA@mail.gmail.com>
 <20181113183510.5y2hzruoi23e7o2t@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
 <CAGqmi763e4sZj1NHAk2fAjtPtb-kAZfcPq=KTH8B3sE-oDVvGw@mail.gmail.com> <20181113191653.btbzobquxtwt47z4@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
In-Reply-To: <20181113191653.btbzobquxtwt47z4@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
From: Timofey Titovets <timofey.titovets@synesis.ru>
Date: Wed, 14 Nov 2018 01:40:10 +0300
Message-ID: <CAGqmi77JMyxU9L4bZHPv4Nt=tyQsEZDQcMVMRfQ7de_LjZg+-Q@mail.gmail.com>
Subject: Re: [PATCH V3] KSM: allow dedup all tasks memory
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Oleksandr Natalenko <oleksandr@natalenko.name>, Jann Horn <jannh@google.com>, linux-doc@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Matthew Wilcox <willy@infradead.org>

=D0=B2=D1=82, 13 =D0=BD=D0=BE=D1=8F=D0=B1. 2018 =D0=B3. =D0=B2 22:17, Pavel=
 Tatashin <pasha.tatashin@soleen.com>:
>
> On 18-11-13 21:54:13, Timofey Titovets wrote:
> > =D0=B2=D1=82, 13 =D0=BD=D0=BE=D1=8F=D0=B1. 2018 =D0=B3. =D0=B2 21:35, P=
avel Tatashin <pasha.tatashin@soleen.com>:
> > >
> > > On 18-11-13 21:17:42, Timofey Titovets wrote:
> > > > =D0=B2=D1=82, 13 =D0=BD=D0=BE=D1=8F=D0=B1. 2018 =D0=B3. =D0=B2 20:5=
9, Pavel Tatashin <pasha.tatashin@soleen.com>:
> > > > >
> > > > > On 18-11-13 15:23:50, Oleksandr Natalenko wrote:
> > > > > > Hi.
> > > > > >
> > > > > > > Yep. However, so far, it requires an application to explicitl=
y opt in
> > > > > > > to this behavior, so it's not all that bad. Your patch would =
remove
> > > > > > > the requirement for application opt-in, which, in my opinion,=
 makes
> > > > > > > this way worse and reduces the number of applications for whi=
ch this
> > > > > > > is acceptable.
> > > > > >
> > > > > > The default is to maintain the old behaviour, so unless the exp=
licit
> > > > > > decision is made by the administrator, no extra risk is imposed=
.
> > > > >
> > > > > The new interface would be more tolerable if it honored MADV_UNME=
RGEABLE:
> > > > >
> > > > > KSM default on: merge everything except when MADV_UNMERGEABLE is
> > > > > excplicitly set.
> > > > >
> > > > > KSM default off: merge only when MADV_MERGEABLE is set.
> > > > >
> > > > > The proposed change won't honor MADV_UNMERGEABLE, meaning that
> > > > > application programmers won't have a way to prevent sensitive dat=
a to be
> > > > > every merged. So, I think, we should keep allow an explicit opt-o=
ut
> > > > > option for applications.
> > > > >
> > > >
> > > > We just did not have VM/Madvise flag for that currently.
> > > > Same as THP.
> > > > Because all logic written with assumption, what we have exactly 2 s=
tates.
> > > > Allow/Disallow (More like not allow).
> > > >
> > > > And if we try to add, that must be something like:
> > > > MADV_FORBID_* to disallow something completely.
> > >
> > > No need to add new user flag MADV_FORBID, we should keep MADV_MERGEAB=
LE
> > > and MADV_UNMERGEABLE, but make them work so when MADV_UNMERGEABLE is
> > > set, memory is indeed becomes always unmergeable regardless of ksm mo=
de
> > > of operation.
> > >
> > > To do the above in ksm_madvise(), a new state should be added, for ex=
ample
> > > instead of:
> > >
> > > case MADV_UNMERGEABLE:
> > >         *vm_flags &=3D ~VM_MERGEABLE;
> > >
> > > A new flag should be used:
> > >         *vm_flags |=3D VM_UNMERGEABLE;
> > >
> > > I think, without honoring MADV_UNMERGEABLE correctly, this patch won'=
t
> > > be accepted.
> > >
> > > Pasha
> > >
> >
> > That must work, but we out of bit space in vm_flags [1].
> > i.e. first 32 bits already defined, and other only accessible only on
> > 64-bit machines.
>
> So, grow vm_flags_t to 64-bit, or enable this feature on 64-bit only.

With all due respect to you, for that type of things we need
mm maintainer opinion.

I just don't want get situation, where after touch of other subsystems,
maintainer will just refuse that work by some reason.

i.e. writing patches for upstream (from my point of view),
is more art of communication and making resulte code acceptable by communit=
y.
Because any code which written correctly from engineering point of view,
can be easy refused, just because someone not found it useful.

Thanks.

> >
> > 1. https://elixir.bootlin.com/linux/latest/source/include/linux/mm.h#L2=
19
