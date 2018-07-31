Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id B97CA6B0005
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 12:56:58 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l4-v6so1999175wme.7
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 09:56:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h19-v6sor694569wmb.88.2018.07.31.09.56.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Jul 2018 09:56:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFx=-tHXjv3gv4W=xYwM+VOHJQE5q5VyihkPK7s560x-vQ@mail.gmail.com>
References: <CA+55aFxpFefwVdTGVML99PSFUqwpJXPx5LVCA3D=g2t2_QLNsA@mail.gmail.com>
 <CAMi1Hd0fJuAgP09_KkbjyGwszOXmxcPybKyBxP3U1y5JUqxxSw@mail.gmail.com>
 <20180730130134.yvn5tcmoavuxtwt5@kshutemo-mobl1> <CA+55aFwxwCPZs=h5wy-5PELwfBVuTETm+wuZB5cM2SDoXJi68g@mail.gmail.com>
 <alpine.LSU.2.11.1807301410470.4805@eggly.anvils> <CA+55aFx3qR1FW0T3na25NrwLZAvpOdUEUJa879CnaJT2ZPfhkg@mail.gmail.com>
 <alpine.LSU.2.11.1807301940460.5904@eggly.anvils> <CALAqxLU3cmu4g+HaB6A7=VhY-hW=d9e68EZ=_4JiwX_BigzjPQ@mail.gmail.com>
 <CAMi1Hd0-2eDod4HiBifKCxY0cUUEW_A-yv7sZ7GRgL0whWQt+w@mail.gmail.com> <CA+55aFx=-tHXjv3gv4W=xYwM+VOHJQE5q5VyihkPK7s560x-vQ@mail.gmail.com>
From: John Stultz <john.stultz@linaro.org>
Date: Tue, 31 Jul 2018 09:56:55 -0700
Message-ID: <CALAqxLXyiE=FkBBwEa0-jhyVb-sp+j8bQR7_+Af8nQw3coKjLA@mail.gmail.com>
Subject: Re: Linux 4.18-rc7
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Amit Pundir <amit.pundir@linaro.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Matthew Wilcox <willy@infradead.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, youling 257 <youling257@gmail.com>, Joel Fernandes <joelaf@google.com>, Colin Cross <ccross@google.com>

On Tue, Jul 31, 2018 at 9:29 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Mon, Jul 30, 2018 at 11:40 PM Amit Pundir <amit.pundir@linaro.org> wrote:
>>
>> This ashmem change ^^ worked too.
>
> Ok, let's go for that one and hope it's the only one.
>
> John, can I get a proper commit message and sign-off for that ashmem change?

Will do. Just doing some local testing myself to make sure all is well.

> Kirill - you mentioned that somebody reproduced a problem on x86-64
> too. I didn't see that report. Was that some odd x86 Android setup
> with Ashmem too, or is there something else pending?

Krill mentioned "zygote crashing, but on x86-64" and zygote is Android
so I assume it is the same issue.

thanks
-john
