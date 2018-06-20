Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E81006B0008
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 20:50:53 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id j13-v6so484927pgp.16
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 17:50:53 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j21-v6sor275791pfk.151.2018.06.19.17.50.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Jun 2018 17:50:52 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH 06/10] x86/cet: Add arch_prctl functions for shadow stack
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <1529447937.27370.33.camel@intel.com>
Date: Tue, 19 Jun 2018 17:50:49 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <13E3C29A-3295-4A7F-90EC-A84CF34F3E1A@amacapital.net>
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
 <446EB18D-EF06-4A04-AF62-E72C68D96A84@amacapital.net> <1529447937.27370.33.camel@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: Kees Cook <keescook@chromium.org>, Andy Lutomirski <luto@kernel.org>, "H. J. Lu" <hjl.tools@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com, Florian Weimer <fweimer@redhat.com>



> On Jun 19, 2018, at 3:38 PM, Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>=20
> On Tue, 2018-06-19 at 13:47 -0700, Andy Lutomirski wrote:
>>>=20
>>> On Jun 19, 2018, at 1:12 PM, Kees Cook <keescook@chromium.org>
>>> wrote:
>>>=20
>>>>=20
>>>> On Tue, Jun 19, 2018 at 10:20 AM, Andy Lutomirski <luto@amacapita
>>>> l.net> wrote:
>>>>=20
>>>>>=20
>>>>> On Jun 19, 2018, at 10:07 AM, Kees Cook <keescook@chromium.org>
>>>>> wrote:
>>>>>=20
>>>>> Does it provide anything beyond what PR_DUMPABLE does?
>>>> What do you mean?
>>> I was just going by the name of it. I wasn't sure what "ptrace CET
>>> lock" meant, so I was trying to understand if it was another "you
>>> can't ptrace me" toggle, and if so, wouldn't it be redundant with
>>> PR_SET_DUMPABLE =3D 0, etc.
>>>=20
>> No, other way around. The valid CET states are on/unlocked,
>> off/unlocked, on/locked, off/locked. arch_prctl can freely the state
>> unless locked. ptrace can change it no matter what.  The lock is to
>> prevent the existence of a gadget to disable CET (unless the gadget
>> involves ptrace, but I don=E2=80=99t think that=E2=80=99s a real concern)=
.
>=20
> We have the arch_prctl now and only need to add ptrace lock/unlock.
>=20
> Back to the dlopen() "relaxed" mode. Would the following work?
>=20
> If the lib being loaded does not use setjmp/getcontext families (the
> loader knows?), then the loader leaves shstk on. =20

Will that actually work?  Are there libs that do something like longjmp with=
out actually using the glibc longjmp routine?  What about compilers that sta=
tically match a throw to a catch and try to return through several frames at=
 once?


> Otherwise, if the
> system-wide setting is "relaxed", the loader turns off shstk and issues
> a warning.  In addition, if (dlopen =3D=3D relaxed), then cet is not locke=
d
> in any time.
>=20
> The system-wide setting (somewhere in /etc?) can be:
>=20
>    dlopen=3Dforce|relaxed /* controls dlopen of non-cet libs */
>    exec=3Dforce|relaxed /* controls exec of non-cet apps */
>=20
>=20

Why do we need a whole new mechanism here?  Can=E2=80=99t all this use regul=
ar glibc tunables?=
