Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id C985E6B0033
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 20:12:44 -0500 (EST)
Received: by mail-yb0-f197.google.com with SMTP id r17so2022456ybm.18
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 17:12:44 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i27sor1647007ybj.131.2018.01.19.17.12.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 19 Jan 2018 17:12:43 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: [kernel-hardening] Re: [PATCH 0/3] exec: Pin stack limit during exec
From: David Windsor <dave@nullcore.net>
In-Reply-To: <CAGXu5jJjHd9D=20jYnx4PSJHBbRsUOP3bAOJ11yyUWutqVHr2A@mail.gmail.com>
Date: Fri, 19 Jan 2018 20:12:40 -0500
Content-Transfer-Encoding: quoted-printable
Message-Id: <8BCDD560-66F5-4CF7-97DD-E2E5BE1D13F4@nullcore.net>
References: <1515529383-35695-1-git-send-email-keescook@chromium.org> <CAGXu5jJjHd9D=20jYnx4PSJHBbRsUOP3bAOJ11yyUWutqVHr2A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Ben Hutchings <ben@decadent.org.uk>, Willy Tarreau <w@1wt.eu>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, "Jason A. Donenfeld" <Jason@zx2c4.com>, Rik van Riel <riel@redhat.com>, Laura Abbott <labbott@redhat.com>, Greg KH <greg@kroah.com>, Andy Lutomirski <luto@kernel.org>, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, kernel-hardening@lists.openwall.com

I have some spare cycles; is there any more relevant information outside of t=
his thread?

Thanks,
David

> On Jan 19, 2018, at 5:49 PM, Kees Cook <keescook@chromium.org> wrote:
>=20
>> On Tue, Jan 9, 2018 at 12:23 PM, Kees Cook <keescook@chromium.org> wrote:=

>> Attempts to solve problems with the stack limit changing during exec
>> continue to be frustrated[1][2]. In addition to the specific issues
>> around the Stack Clash family of flaws, Andy Lutomirski pointed out[3]
>> other places during exec where the stack limit is used and is assumed
>> to be unchanging. Given the many places it gets used and the fact that
>> it can be manipulated/raced via setrlimit() and prlimit(), I think the
>> only way to handle this is to move away from the "current" view of the
>> stack limit and instead attach it to the bprm, and plumb this down into
>> the functions that need to know the stack limits. This series implements
>> the approach. I'd be curious to hear feedback on alternatives.
>=20
> Friendly ping -- looking for some people with spare cycles to look
> this over. If people want, I can toss it into -next as part of my kspp
> tree. It's been living happily in 0-day for  2 weeks...
>=20
> Thanks!
>=20
> -Kees
>=20
>> [1] 04e35f4495dd ("exec: avoid RLIMIT_STACK races with prlimit()")
>> [2] 779f4e1c6c7c ("Revert "exec: avoid RLIMIT_STACK races with prlimit()"=
")
>> [3] to security@kernel.org, "Subject: existing rlimit races?"
>=20
> --=20
> Kees Cook
> Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
