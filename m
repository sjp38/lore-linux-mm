Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D16E16B000A
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 01:55:35 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id v25-v6so11838453pfm.11
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 22:55:35 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f70-v6sor5526773pfd.104.2018.07.12.22.55.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Jul 2018 22:55:34 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [RFC PATCH v2 18/27] x86/cet/shstk: Introduce WRUSS instruction
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <66016722-9872-a3f9-f88b-37397f9b6979@intel.com>
Date: Thu, 12 Jul 2018 22:55:30 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <7E04B6EB-8EEE-4A09-9C41-017D31A1A748@amacapital.net>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com> <20180710222639.8241-19-yu-cheng.yu@intel.com> <bbb487cc-ac1c-f734-eee3-2463a0ba7efc@linux.intel.com> <1531436398.2965.18.camel@intel.com> <46784af0-6fbb-522d-6acb-c6248e5e0e0d@linux.intel.com> <167645aa-f1c7-bd6a-c7e0-2da317cbbaba@intel.com> <55A0592D-0E8D-4BC5-BA4B-E82E92EEA36A@amacapital.net> <66016722-9872-a3f9-f88b-37397f9b6979@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>



> On Jul 12, 2018, at 9:16 PM, Dave Hansen <dave.hansen@intel.com> wrote:
>=20
>> On 07/12/2018 07:21 PM, Andy Lutomirski wrote:
>> I am tempted to suggest that the whole series not be merged until
>> there are actual docs. It=E2=80=99s not a fantastic precedent.
>=20
> Do you mean Documentation or manpages, or are you talking about hardware
> documentation?
> https://software.intel.com/sites/default/files/managed/4d/2a/control-flow-=
enforcement-technology-preview.pdf

I mean hardware docs. The =E2=80=9Cpreview=E2=80=9D is a little bit dubious I=
MO.=
