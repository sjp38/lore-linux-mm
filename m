Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 83EF26B0003
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 13:03:35 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id d12-v6so9559808pgv.12
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 10:03:35 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m4-v6sor4378380plt.32.2018.07.31.10.03.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Jul 2018 10:03:34 -0700 (PDT)
Date: Tue, 31 Jul 2018 20:03:28 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: Linux 4.18-rc7
Message-ID: <20180731170328.ocb5oikwhwtkyzrj@kshutemo-mobl1>
References: <CA+55aFxpFefwVdTGVML99PSFUqwpJXPx5LVCA3D=g2t2_QLNsA@mail.gmail.com>
 <CAMi1Hd0fJuAgP09_KkbjyGwszOXmxcPybKyBxP3U1y5JUqxxSw@mail.gmail.com>
 <20180730130134.yvn5tcmoavuxtwt5@kshutemo-mobl1>
 <CA+55aFwxwCPZs=h5wy-5PELwfBVuTETm+wuZB5cM2SDoXJi68g@mail.gmail.com>
 <alpine.LSU.2.11.1807301410470.4805@eggly.anvils>
 <CA+55aFx3qR1FW0T3na25NrwLZAvpOdUEUJa879CnaJT2ZPfhkg@mail.gmail.com>
 <alpine.LSU.2.11.1807301940460.5904@eggly.anvils>
 <CALAqxLU3cmu4g+HaB6A7=VhY-hW=d9e68EZ=_4JiwX_BigzjPQ@mail.gmail.com>
 <CAMi1Hd0-2eDod4HiBifKCxY0cUUEW_A-yv7sZ7GRgL0whWQt+w@mail.gmail.com>
 <CA+55aFx=-tHXjv3gv4W=xYwM+VOHJQE5q5VyihkPK7s560x-vQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CA+55aFx=-tHXjv3gv4W=xYwM+VOHJQE5q5VyihkPK7s560x-vQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, "Luck, Tony" <tony.luck@intel.com>
Cc: Amit Pundir <amit.pundir@linaro.org>, John Stultz <john.stultz@linaro.org>, Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, youling 257 <youling257@gmail.com>, Joel Fernandes <joelaf@google.com>, Colin Cross <ccross@google.com>

On Tue, Jul 31, 2018 at 09:29:22AM -0700, Linus Torvalds wrote:
> On Mon, Jul 30, 2018 at 11:40 PM Amit Pundir <amit.pundir@linaro.org> wrote:
> >
> > This ashmem change ^^ worked too.
> 
> Ok, let's go for that one and hope it's the only one.
> 
> John, can I get a proper commit message and sign-off for that ashmem change?
> 
> Kirill - you mentioned that somebody reproduced a problem on x86-64
> too. I didn't see that report. Was that some odd x86 Android setup
> with Ashmem too, or is there something else pending?

I've got report from youling privately:

"mm: fix vma_is_anonymous() false-positives" cause my userspace boot failedi 1/4 ?
our Androidx86 userspace can running on linux mainline kerneli 1/4 ?
revert it boot succeed with 4.18rc7 kernel.

"mm: fix vma_is_anonymous() false-positives" cause these

07-30 11:04:19.556 1609 1609 F DEBUG : pid: 1304, tid: 1304, name: zygote
>>> zygote <<<
07-30 11:04:19.556 1609 1609 F DEBUG : signal 7 (SIGBUS), code 2
(BUS_ADRERR), fault addr 0x7494d008
07-30 11:04:19.556 1609 1609 F DEBUG : eax 00000000 ebx f337bb68 ecx
000001e0 edx 7494d008
07-30 11:04:19.556 1609 1609 F DEBUG : esi 7494d000 edi 00000000
07-30 11:04:19.556 1609 1609 F DEBUG : xcs 00000023 xds 0000002b xes
0000002b xfs 00000003 xss 0000002b
07-30 11:04:19.556 1609 1609 F DEBUG : eip f40f5c76 ebp ffa8d288 esp
ffa8d238 flags 00010202
07-30 11:04:19.581 1609 1609 F DEBUG :

-------------------------------------------------------------------------

The report also had screenshot attached about system info. It's a Baytrail
tablet with LinageOS, so I believe it's the same issue.

But it's not the only issue unfortunately. Tony reported issue with
booting ia64 with the patch. I have no clue why. I rechecked everything
ia64-specific and looks fine to me. :-/

-- 
 Kirill A. Shutemov
