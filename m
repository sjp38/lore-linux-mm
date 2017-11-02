Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6BA5D6B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 14:19:57 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id h28so322694pfh.16
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 11:19:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l8sor1227189pln.81.2017.11.02.11.19.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 Nov 2017 11:19:56 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH 02/23] x86, kaiser: do not set _PAGE_USER for init_mm page tables
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <c4a5395b-5869-d088-9819-8457d138dc43@linux.intel.com>
Date: Thu, 2 Nov 2017 19:19:49 +0100
Content-Transfer-Encoding: quoted-printable
Message-Id: <DADF7172-F2ED-4C2A-B921-8707DEDEABD7@amacapital.net>
References: <20171031223146.6B47C861@viggo.jf.intel.com> <20171031223150.AB41C68F@viggo.jf.intel.com> <alpine.DEB.2.20.1711012206050.1942@nanos> <CALCETrWQ0W=Kp7fycZ2E9Dp84CCPOr1nEmsPom71ZAXeRYqr9g@mail.gmail.com> <alpine.DEB.2.20.1711012225400.1942@nanos> <e8149c9e-10f8-aa74-ff0e-e2de923b2128@linux.intel.com> <CA+55aFyijHb4WnDMKgeXekTZHYT8pajqSAu2peo3O4EKiZbYPA@mail.gmail.com> <alpine.DEB.2.20.1711012316130.1942@nanos> <CALCETrWS2Tqn=hthSnzxKj3tJrgK+HH2Nkdv-GiXA7bkHUBdcQ@mail.gmail.com> <alpine.DEB.2.20.1711021226020.2090@nanos> <c4a5395b-5869-d088-9819-8457d138dc43@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Andy Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>



> On Nov 2, 2017, at 5:38 PM, Dave Hansen <dave.hansen@linux.intel.com> wrot=
e:
>=20
>> On 11/02/2017 04:33 AM, Thomas Gleixner wrote:
>> So for the problem at hand, I'd suggest we disable the vsyscall stuff if
>> CONFIG_KAISER=3Dy and be done with it.
>=20
> Just to be clear, are we suggesting to just disable
> LEGACY_VSYSCALL_NATIVE if KAISER=3Dy, and allow LEGACY_VSYSCALL_EMULATE?
> Or, do we just force LEGACY_VSYSCALL_NONE=3Dy?

We'd have to force NONE, and Linus won't like it.=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
