Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 772926B0005
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 16:47:36 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 70-v6so456023plc.1
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 13:47:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b6-v6sor209435plk.85.2018.06.19.13.47.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Jun 2018 13:47:35 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH 06/10] x86/cet: Add arch_prctl functions for shadow stack
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <CAGXu5jLEMy_T_5OtXLT+pUCt=Nk53nBbuRvrUgJBhq-4RZ=yCA@mail.gmail.com>
Date: Tue, 19 Jun 2018 13:47:32 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <446EB18D-EF06-4A04-AF62-E72C68D96A84@amacapital.net>
References: <20180607143807.3611-1-yu-cheng.yu@intel.com> <20180607143807.3611-7-yu-cheng.yu@intel.com>
 <CALCETrU6axo158CiSCRRkC4GC5hib9hypC98t7LLjA3gDaacsw@mail.gmail.com>
 <1528403417.5265.35.camel@2b52.sc.intel.com> <CALCETrXz3WWgZwUXJsDTWvmqKUArQFuMH1xJdSLVKFpTysNWxg@mail.gmail.com>
 <CAMe9rOr49V8rqRa_KVsw61PWd+crkQvPDgPKtvowazjmsfgWWQ@mail.gmail.com>
 <alpine.DEB.2.21.1806121155450.2157@nanos.tec.linutronix.de>
 <CAMe9rOoCiXQ4iVD3j_AHGrvEXtoaVVZVs7H7fCuqNEuuR5j+2Q@mail.gmail.com>
 <CALCETrXO8R+RQPhJFk4oiA4PF77OgSS2Yro_POXQj1zvdLo61A@mail.gmail.com>
 <CAMe9rOpLxPussn7gKvn0GgbOB4f5W+DKOGipe_8NMam+Afd+RA@mail.gmail.com>
 <CALCETrWmGRkQvsUgRaj+j0CP4beKys+TT5aDR5+18nuphwr+Cw@mail.gmail.com>
 <CAMe9rOpzcCdje=bUVs+C1WrY6GuwA-8AUFVLOG325LGz7KHJxw@mail.gmail.com>
 <alpine.DEB.2.21.1806122046520.1592@nanos.tec.linutronix.de>
 <CAMe9rOrGjJf0aMnUjAP38MqvOiW3=iXGQjcUT3O=f9pE85hXaw@mail.gmail.com>
 <CALCETrVsh5t-V1Sm88LsZE_+DS0GE_bMWbcoX3SjD6GnrB08Pw@mail.gmail.com>
 <CAGXu5jK0gospOXRpN6zYiQPXOZeE=YpVAz2qu4Zc3-32v85+EQ@mail.gmail.com>
 <569B4719-6283-4575-A16E-D0A78D280F4E@amacapital.net> <CAGXu5jJNgu4bW_Zthqjfpe9gLxK0zxG8QFEqqK+pJNebz6tUaw@mail.gmail.com>
 <1529427588.23068.7.camel@intel.com> <CAGXu5jJ4ivrvi-kG0iY=4C0mQQXBDXwPdfY36Dk+JqOpX19n0w@mail.gmail.com>
 <0AF8B71E-B6CC-42DE-B95C-93896196C3D7@amacapital.net> <CAGXu5jLEMy_T_5OtXLT+pUCt=Nk53nBbuRvrUgJBhq-4RZ=yCA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>, Andy Lutomirski <luto@kernel.org>, "H. J. Lu" <hjl.tools@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com, Florian Weimer <fweimer@redhat.com>


> On Jun 19, 2018, at 1:12 PM, Kees Cook <keescook@chromium.org> wrote:
>=20
>> On Tue, Jun 19, 2018 at 10:20 AM, Andy Lutomirski <luto@amacapital.net> w=
rote:
>>=20
>>> On Jun 19, 2018, at 10:07 AM, Kees Cook <keescook@chromium.org> wrote:
>>>=20
>>> Does it provide anything beyond what PR_DUMPABLE does?
>>=20
>> What do you mean?
>=20
> I was just going by the name of it. I wasn't sure what "ptrace CET
> lock" meant, so I was trying to understand if it was another "you
> can't ptrace me" toggle, and if so, wouldn't it be redundant with
> PR_SET_DUMPABLE =3D 0, etc.
>=20

No, other way around. The valid CET states are on/unlocked, off/unlocked, on=
/locked, off/locked. arch_prctl can freely the state unless locked. ptrace c=
an change it no matter what.  The lock is to prevent the existence of a gadg=
et to disable CET (unless the gadget involves ptrace, but I don=E2=80=99t th=
ink that=E2=80=99s a real concern).=
