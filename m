Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 50B436B0546
	for <linux-mm@kvack.org>; Thu, 17 May 2018 17:12:14 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id h70-v6so2973258iof.10
        for <linux-mm@kvack.org>; Thu, 17 May 2018 14:12:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g21-v6sor1388331itd.82.2018.05.17.14.12.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 May 2018 14:12:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALCETrWE3Y_GQfBtCjC4LbyWcAdt3bZKQTGdkjbS03ivoQ58hQ@mail.gmail.com>
References: <82328ad006ebacb399d04d638f8dad4a@ispras.ru> <CALCETrWRfW2jrDDp6SGb62tpHykK7U-fWmdxtK15LMWL_Gkqqw@mail.gmail.com>
 <CAJwJo6aaYwf1ZzwxNtawsaxtWj9cZgPukVAzGru3H68gN+ZDgw@mail.gmail.com> <CALCETrWE3Y_GQfBtCjC4LbyWcAdt3bZKQTGdkjbS03ivoQ58hQ@mail.gmail.com>
From: Dmitry Safonov <0x7f454c46@gmail.com>
Date: Thu, 17 May 2018 22:11:52 +0100
Message-ID: <CAJwJo6Zad1S_Ontm3-oUjrtxdsz+sTfgufCcskpYfik=pOxd=g@mail.gmail.com>
Subject: Re: [4.11 Regression] 64-bit process gets AT_BASE in the first 4 GB
 if exec'ed from 32-bit process
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: izbyshev@ispras.ru, Dmitry Safonov <dsafonov@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alexander Monakov <amonakov@ispras.ru>, Linux-MM <linux-mm@kvack.org>

2018-05-17 22:07 GMT+01:00 Andy Lutomirski <luto@kernel.org>:
> On Thu, May 17, 2018 at 1:51 PM Dmitry Safonov <0x7f454c46@gmail.com> wrote:
>
>> 2018-05-17 21:46 GMT+01:00 Andy Lutomirski <luto@kernel.org>:
>> > On Thu, May 17, 2018 at 1:25 PM Alexey Izbyshev <izbyshev@ispras.ru>
> wrote:
>> >
>> >> Hello everyone,
>> >
>> >> I've discovered the following strange behavior of a 4.15.13-based
> kernel
>> >> (bisected to
>> >
>> >
>> >
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=1b028f784e8c341e762c264f70dc0ca1418c8b7a
>> >> between 4.11-rc2 and -rc3 thanks to Alexander Monakov).
>> >
>> >
>> > It's definitely not intended.  Can you confirm that the problem still
>> > exists in 4.16?  I have some vague recollection that this was a known
> issue
>> > that got fixed, and we could plausibly just be missing a backport.
>
>> I'm looking into that ATM, the problem like that was fixed with
>
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=ada26481dfe6
>
>> Will check what's happening there.
>
> I haven't tried to figure out exactly what code calls which function, but
> it seems like set_personality_64bit() really ought to clear TS_COMPAT.

Ugh, yeah, the same way __set_personality_x32().
Will test it and prepare a patch for that Cc'ing stable.

Thanks, Alexey, Andy!

Sorry about asan breakage,
             Dmitry
