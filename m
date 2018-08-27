Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id A773C6B4129
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 11:28:58 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id a7-v6so843873lfe.7
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 08:28:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e82-v6sor1358397lff.145.2018.08.27.08.28.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Aug 2018 08:28:57 -0700 (PDT)
MIME-Version: 1.0
References: <20180703123910.2180-1-willy@infradead.org> <20180703123910.2180-2-willy@infradead.org>
 <alpine.DEB.2.21.1807161116590.2644@nanos.tec.linutronix.de>
 <CAFqt6zbgoTgw1HNp+anOYY8CiU1BPoNeeddsnGGXWY_hVOd5iQ@mail.gmail.com> <alpine.DEB.2.21.1808031503370.1745@nanos.tec.linutronix.de>
In-Reply-To: <alpine.DEB.2.21.1808031503370.1745@nanos.tec.linutronix.de>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Mon, 27 Aug 2018 21:01:48 +0530
Message-ID: <CAFqt6zbJq9kca8dHDVAs-MOWNZgo2C=id3Cp4M0C76MQDXevJg@mail.gmail.com>
Subject: Re: [PATCH 2/3] x86: Convert vdso to use vm_fault_t
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, linux-kernel@vger.kernel.org, Brajeswar Ghosh <brajeswar.linux@gmail.com>, Sabyasachi Gupta <sabyasachi.linux@gmail.com>, Linux-MM <linux-mm@kvack.org>

On Fri, Aug 3, 2018 at 6:44 PM Thomas Gleixner <tglx@linutronix.de> wrote:
>
> On Fri, 3 Aug 2018, Souptick Joarder wrote:
> > On Mon, Jul 16, 2018 at 2:47 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> > > On Tue, 3 Jul 2018, Matthew Wilcox wrote:
> > >
> > >> Return vm_fault_t codes directly from the appropriate mm routines instead
> > >> of converting from errnos ourselves.  Fixes a minor bug where we'd return
> > >> SIGBUS instead of the correct OOM code if we ran out of memory allocating
> > >> page tables.
> > >>
> > >> Signed-off-by: Matthew Wilcox <willy@infradead.org>
> > >
> > > Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
> > >
> >
> > Thomas, are these 3 patches part of this series will be queued
> > for 4.19 ?
>
> I don't know. I expected that these go through the mm tree, but if nobody
> feels responsible, I could pick up the whole lot. But I'd like to see acks
> from the mm folks for [1/3] and [3/3]
>
>   https://lkml.kernel.org/r/20180703123910.2180-1-willy@infradead.org
>
> Thanks,
>
>         tglx
>

Any comment from mm reviewers for patch [1/3] and [3/3] ??

https://lkml.kernel.org/r/20180703123910.2180-1-willy@infradead.org
