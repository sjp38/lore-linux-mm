Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 39F596B0003
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 18:07:51 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id m52so3522450otc.13
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 15:07:51 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r1-v6sor11031854oie.99.2018.11.13.15.07.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Nov 2018 15:07:50 -0800 (PST)
Received: from mail-oi1-f178.google.com (mail-oi1-f178.google.com. [209.85.167.178])
        by smtp.gmail.com with ESMTPSA id u8sm11127308ota.81.2018.11.13.15.07.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Nov 2018 15:07:48 -0800 (PST)
Received: by mail-oi1-f178.google.com with SMTP id j202-v6so11925680oih.10
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 15:07:48 -0800 (PST)
MIME-Version: 1.0
References: <CAG48ez0ZprqUYGZFxcrY6U3Dnwt77q1NJXzzpsn1XNkRuXVppw@mail.gmail.com>
 <d43da6ad1a3c164aa03e0f22f065591a@natalenko.name> <20181113175930.3g65rlhbaimstq7g@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
 <CAGqmi74gpvJv8=B-3pVSMrDssu-aYMxW9xM7mt1WNQjGLjMZqA@mail.gmail.com>
 <20181113183510.5y2hzruoi23e7o2t@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
 <CAGqmi763e4sZj1NHAk2fAjtPtb-kAZfcPq=KTH8B3sE-oDVvGw@mail.gmail.com>
 <20181113191653.btbzobquxtwt47z4@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
 <CAGqmi77JMyxU9L4bZHPv4Nt=tyQsEZDQcMVMRfQ7de_LjZg+-Q@mail.gmail.com> <20181113225334.hnz7pqoldvvg6j3w@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
In-Reply-To: <20181113225334.hnz7pqoldvvg6j3w@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
From: Timofey Titovets <timofey.titovets@synesis.ru>
Date: Wed, 14 Nov 2018 02:07:11 +0300
Message-ID: <CAGqmi75sk7A7y=urhyEJ=Wf5Dvv7y48DgPzQP-335s_JV0g+2g@mail.gmail.com>
Subject: Re: [PATCH V3] KSM: allow dedup all tasks memory
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Oleksandr Natalenko <oleksandr@natalenko.name>, Jann Horn <jannh@google.com>, linux-doc@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Matthew Wilcox <willy@infradead.org>

=D1=81=D1=80, 14 =D0=BD=D0=BE=D1=8F=D0=B1. 2018 =D0=B3. =D0=B2 01:53, Pavel=
 Tatashin <pasha.tatashin@soleen.com>:
>
> > > > That must work, but we out of bit space in vm_flags [1].
> > > > i.e. first 32 bits already defined, and other only accessible only =
on
> > > > 64-bit machines.
> > >
> > > So, grow vm_flags_t to 64-bit, or enable this feature on 64-bit only.
> >
> > With all due respect to you, for that type of things we need
> > mm maintainer opinion.
>
> As far as I understood, you already got directions from the maintainers
> to do similar to the way THP is implemented, and THP uses two flags:
>
> VM_HUGEPAGE VM_NOHUGEPAGE, the same as I am thinking ksm should do if we
> honor MADV_UNMERGEABLE.
>
> When VM_NOHUGEPAGE is set khugepaged ignores those VMAs.
>
> There may be a way to add VM_UNMERGEABLE without extending the size of
> vm_flags, but that would be a good start point in looking how to add a
> new flag.
>
> Again, you could simply enable this feature on 64-bit only.
>
> Pasha
>

Deal!
I will try with only on 64bit machines.
