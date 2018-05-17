Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 560876B053C
	for <linux-mm@kvack.org>; Thu, 17 May 2018 16:51:02 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id s2-v6so2896416ioa.22
        for <linux-mm@kvack.org>; Thu, 17 May 2018 13:51:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h191-v6sor3382940itb.96.2018.05.17.13.51.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 17 May 2018 13:51:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALCETrWRfW2jrDDp6SGb62tpHykK7U-fWmdxtK15LMWL_Gkqqw@mail.gmail.com>
References: <82328ad006ebacb399d04d638f8dad4a@ispras.ru> <CALCETrWRfW2jrDDp6SGb62tpHykK7U-fWmdxtK15LMWL_Gkqqw@mail.gmail.com>
From: Dmitry Safonov <0x7f454c46@gmail.com>
Date: Thu, 17 May 2018 21:50:40 +0100
Message-ID: <CAJwJo6aaYwf1ZzwxNtawsaxtWj9cZgPukVAzGru3H68gN+ZDgw@mail.gmail.com>
Subject: Re: [4.11 Regression] 64-bit process gets AT_BASE in the first 4 GB
 if exec'ed from 32-bit process
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: izbyshev@ispras.ru, Dmitry Safonov <dsafonov@virtuozzo.com>, Thomas Gleixner <tglx@linutronix.de>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alexander Monakov <amonakov@ispras.ru>, Linux-MM <linux-mm@kvack.org>

2018-05-17 21:46 GMT+01:00 Andy Lutomirski <luto@kernel.org>:
> On Thu, May 17, 2018 at 1:25 PM Alexey Izbyshev <izbyshev@ispras.ru> wrote:
>
>> Hello everyone,
>
>> I've discovered the following strange behavior of a 4.15.13-based kernel
>> (bisected to
>
>
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=1b028f784e8c341e762c264f70dc0ca1418c8b7a
>> between 4.11-rc2 and -rc3 thanks to Alexander Monakov).
>
>
> It's definitely not intended.  Can you confirm that the problem still
> exists in 4.16?  I have some vague recollection that this was a known issue
> that got fixed, and we could plausibly just be missing a backport.

I'm looking into that ATM, the problem like that was fixed with
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=ada26481dfe6

Will check what's happening there.

Thanks,
             Dmitry
