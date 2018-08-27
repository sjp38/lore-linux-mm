Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua1-f72.google.com (mail-ua1-f72.google.com [209.85.222.72])
	by kanga.kvack.org (Postfix) with ESMTP id ED98B6B4052
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 07:45:15 -0400 (EDT)
Received: by mail-ua1-f72.google.com with SMTP id l22-v6so7344020uak.2
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 04:45:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d3-v6sor5368717uae.119.2018.08.27.04.45.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Aug 2018 04:45:14 -0700 (PDT)
MIME-Version: 1.0
References: <20180823134525.5f12b0d3@roar.ozlabs.ibm.com> <CA+55aFxneZTFxxxAjLZmj92VUJg6z7hERxJ2cHoth-GC0RuELw@mail.gmail.com>
 <776104d4c8e4fc680004d69e3a4c2594b638b6d1.camel@au1.ibm.com>
 <CA+55aFzM77G9-Q6LboPLJ=5gHma66ZQKiMGCMqXoKABirdF98w@mail.gmail.com>
 <20180823133958.GA1496@brain-police> <20180824084717.GK24124@hirez.programming.kicks-ass.net>
 <20180824113214.GK24142@hirez.programming.kicks-ass.net> <20180824113953.GL24142@hirez.programming.kicks-ass.net>
 <20180827150008.13bce08f@roar.ozlabs.ibm.com> <20180827074701.GW24124@hirez.programming.kicks-ass.net>
 <20180827085708.GA27172@infradead.org>
In-Reply-To: <20180827085708.GA27172@infradead.org>
From: Jason Duerstock <evilmoo@gmail.com>
Date: Mon, 27 Aug 2018 07:45:03 -0400
Message-ID: <CAP5F8cK7Yik27YT32EeJi1Hm19HFVA5bRmCbrd8ytnHQWtOEUg@mail.gmail.com>
Subject: Re: removig ia64, was: Re: [PATCH 3/4] mm/tlb, x86/mm: Support
 invalidating TLB caches for RCU_TABLE_FREE
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hch@infradead.org
Cc: peterz@infradead.org, npiggin@gmail.com, will.deacon@arm.com, torvalds@linux-foundation.org, benh@au1.ibm.com, luto@kernel.org, x86@kernel.org, bp@alien8.de, riel@surriel.com, jannh@google.com, ascannell@google.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, davem@davemloft.net, schwidefsky@de.ibm.com, mpe@ellerman.id.au, tony.luck@intel.com, fenghua.yu@intel.com, linux-ia64@vger.kernel.org

I cannot speak to how widespread it has been adopted, but the linux
(kernel) package for version 4.17.17 has been successfully built and
installed for ia64 under Debian ports.  There is clearly more work to
do to get ia64 rehabilitated, but there are over 10,000 packages
currently successfully built for ia64 under Debian ports[1].

Jason

[1] https://buildd.debian.org/status/architecture.php?a=ia64&suite=sid
On Mon, Aug 27, 2018 at 4:57 AM Christoph Hellwig <hch@infradead.org> wrote:
>
> On Mon, Aug 27, 2018 at 09:47:01AM +0200, Peter Zijlstra wrote:
> > sh is trivial, arm seems doable, with a bit of luck we can do 'rm -rf
> > arch/ia64' leaving us with s390.
>
> Is removing ia64 a serious plan?  It is the cause for a fair share of
> oddities in dma lang, and I did not have much luck getting maintainer
> replies lately, but I didn't know of a plan to get rid of it.
>
> What is the state of people still using ia64 mainline kernels vs just
> old distros in the still existing machines?
