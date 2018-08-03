Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0387A6B0006
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 09:14:54 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id p12-v6so787300wro.7
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 06:14:53 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id f42-v6si3761242wrf.336.2018.08.03.06.14.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 03 Aug 2018 06:14:52 -0700 (PDT)
Date: Fri, 3 Aug 2018 15:14:31 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 2/3] x86: Convert vdso to use vm_fault_t
In-Reply-To: <CAFqt6zbgoTgw1HNp+anOYY8CiU1BPoNeeddsnGGXWY_hVOd5iQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.21.1808031503370.1745@nanos.tec.linutronix.de>
References: <20180703123910.2180-1-willy@infradead.org> <20180703123910.2180-2-willy@infradead.org> <alpine.DEB.2.21.1807161116590.2644@nanos.tec.linutronix.de> <CAFqt6zbgoTgw1HNp+anOYY8CiU1BPoNeeddsnGGXWY_hVOd5iQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Brajeswar Ghosh <brajeswar.linux@gmail.com>, Sabyasachi Gupta <sabyasachi.linux@gmail.com>, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri, 3 Aug 2018, Souptick Joarder wrote:
> On Mon, Jul 16, 2018 at 2:47 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> > On Tue, 3 Jul 2018, Matthew Wilcox wrote:
> >
> >> Return vm_fault_t codes directly from the appropriate mm routines instead
> >> of converting from errnos ourselves.  Fixes a minor bug where we'd return
> >> SIGBUS instead of the correct OOM code if we ran out of memory allocating
> >> page tables.
> >>
> >> Signed-off-by: Matthew Wilcox <willy@infradead.org>
> >
> > Reviewed-by: Thomas Gleixner <tglx@linutronix.de>
> >
> 
> Thomas, are these 3 patches part of this series will be queued
> for 4.19 ?

I don't know. I expected that these go through the mm tree, but if nobody
feels responsible, I could pick up the whole lot. But I'd like to see acks
from the mm folks for [1/3] and [3/3]

  https://lkml.kernel.org/r/20180703123910.2180-1-willy@infradead.org

Thanks,

	tglx
