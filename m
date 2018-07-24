Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id C911C6B026B
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 10:39:41 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id t1-v6so3064968ply.16
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 07:39:41 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z4-v6sor3327608pff.50.2018.07.24.07.39.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Jul 2018 07:39:40 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH 0/3] PTI for x86-32 Fixes and Updates
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <20180724133935.GA30797@amd>
Date: Tue, 24 Jul 2018 07:39:38 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <17482884-2DC3-4A09-8AAC-01AC4D8DE293@amacapital.net>
References: <1532103744-31902-1-git-send-email-joro@8bytes.org> <20180723140925.GA4285@amd> <CA+55aFynT9Sp7CbnB=GqLbns7GFZbv3pDSQm_h0jFvJpz3ES+g@mail.gmail.com> <20180724133935.GA30797@amd>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, =?utf-8?Q?J=C3=BCrgen_Gro=C3=9F?= <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, Joerg Roedel <jroedel@suse.de>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>



> On Jul 24, 2018, at 6:39 AM, Pavel Machek <pavel@ucw.cz> wrote:
>=20
>> On Mon 2018-07-23 12:00:08, Linus Torvalds wrote:
>>> On Mon, Jul 23, 2018 at 7:09 AM Pavel Machek <pavel@ucw.cz> wrote:
>>>=20
>>> Meanwhile... it looks like gcc is not slowed down significantly, but
>>> other stuff sees 30% .. 40% slowdowns... which is rather
>>> significant.
>>=20
>> That is more or less expected.
>=20
> Ok, so I was wrong. bzip2 showed 30% slowdown, but running test in a
> loop, I get (on v4.18) that, too.
>=20
>=20

...

The obvious cause would be thermal issues, which are increasingly common in l=
aptops.  You could get cycle counts from perf stat, perhaps.
