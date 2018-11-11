Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0BF826B0003
	for <linux-mm@kvack.org>; Sun, 11 Nov 2018 09:59:30 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id r16so4000255pgr.15
        for <linux-mm@kvack.org>; Sun, 11 Nov 2018 06:59:30 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q204sor15160181pgq.70.2018.11.11.06.59.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 11 Nov 2018 06:59:28 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH v5 04/27] x86/fpu/xstate: Add XSAVES system states for shadow stack
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <20181111113103.GG27666@amd>
Date: Sun, 11 Nov 2018 06:59:24 -0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <4E917DA9-5192-48E2-8857-08C3ABE08AFE@amacapital.net>
References: <20181011151523.27101-1-yu-cheng.yu@intel.com> <20181011151523.27101-5-yu-cheng.yu@intel.com> <20181108184038.GJ7543@zn.tnic> <20181111113103.GG27666@amd>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Borislav Petkov <bp@alien8.de>, Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>



> On Nov 11, 2018, at 3:31 AM, Pavel Machek <pavel@ucw.cz> wrote:
>=20
> Hi!
>=20
>>> +/*
>>> + * State component 12 is Control flow Enforcement kernel states
>>> + */
>>> +struct cet_kernel_state {
>>> +    u64 kernel_ssp;    /* kernel shadow stack */
>>> +    u64 pl1_ssp;    /* ring-1 shadow stack */
>>> +    u64 pl2_ssp;    /* ring-2 shadow stack */
>>=20
>> Just write "privilege level" everywhere - not "ring".
>=20
> Please just use word "ring". It is well estabilished terminology.
>=20
> Which ring is priviledge level 1, given that we have SMM and
> virtualization support?

To the contrary: CPL, DPL, and RPL are very well defined terms in the archit=
ecture manuals. =E2=80=9CPL=E2=80=9D is privilege level. PL 1 is very well d=
efined.

SMM is SMM, full stop (unless dual mode or whatever it=E2=80=99s called is o=
n, but AFAIK no one uses it).  VMX non-root CPL 1 is *still* privilege level=
 1.

In contrast, the security community likes to call SMM =E2=80=9Cring -1=E2=80=
=9D, which is cute, but wrong from a systems programmer view. For example, S=
MM=E2=80=99s CPL can still range from 0-3.

>=20
>                                    Pavel
> --=20
> (english) http://www.livejournal.com/~pavelmachek
> (cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/bl=
og.html
