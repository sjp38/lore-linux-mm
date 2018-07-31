Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id A8A5D6B0006
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 15:02:58 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id g4-v6so4875640iti.0
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 12:02:58 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p3-v6sor1224837ita.27.2018.07.31.12.02.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Jul 2018 12:02:57 -0700 (PDT)
MIME-Version: 1.0
References: <CAMi1Hd0fJuAgP09_KkbjyGwszOXmxcPybKyBxP3U1y5JUqxxSw@mail.gmail.com>
 <20180730130134.yvn5tcmoavuxtwt5@kshutemo-mobl1> <CA+55aFwxwCPZs=h5wy-5PELwfBVuTETm+wuZB5cM2SDoXJi68g@mail.gmail.com>
 <alpine.LSU.2.11.1807301410470.4805@eggly.anvils> <CA+55aFx3qR1FW0T3na25NrwLZAvpOdUEUJa879CnaJT2ZPfhkg@mail.gmail.com>
 <alpine.LSU.2.11.1807301940460.5904@eggly.anvils> <CALAqxLU3cmu4g+HaB6A7=VhY-hW=d9e68EZ=_4JiwX_BigzjPQ@mail.gmail.com>
 <CAMi1Hd0-2eDod4HiBifKCxY0cUUEW_A-yv7sZ7GRgL0whWQt+w@mail.gmail.com>
 <CA+55aFx=-tHXjv3gv4W=xYwM+VOHJQE5q5VyihkPK7s560x-vQ@mail.gmail.com>
 <20180731170328.ocb5oikwhwtkyzrj@kshutemo-mobl1> <20180731174349.GA12944@agluck-desk>
In-Reply-To: <20180731174349.GA12944@agluck-desk>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 31 Jul 2018 12:02:45 -0700
Message-ID: <CA+55aFzHRaNMHxLCEa5Zke-1FgbQ4rtHf8-HOu0zBzo4Liz88A@mail.gmail.com>
Subject: Re: Linux 4.18-rc7
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Amit Pundir <amit.pundir@linaro.org>, John Stultz <john.stultz@linaro.org>, Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, youling 257 <youling257@gmail.com>, Joel Fernandes <joelaf@google.com>, Colin Cross <ccross@google.com>

On Tue, Jul 31, 2018 at 10:43 AM Luck, Tony <tony.luck@intel.com> wrote:
>
> If I just revert bfd40eaff5ab ("mm: fix vma_is_anonymous() false-positives")
> then ia64 boots again.

Ok, so it's not just the ashmem thing.

I think I'll do an rc8 with the revert, just so that we'll have some
time to figure this out. It's only Tuesday, but I already have 90
commits since rc7, so this isn't the only issue we're having.

I _prefer_ just the regular cadence of releases, but when I have a
reason to delay, I'll delay.

                 Linus
