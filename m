Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1B42F6B0007
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 21:11:43 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id h14-v6so1855157pfi.19
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 18:11:43 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k9-v6si3340865pgs.681.2018.06.27.18.11.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 18:11:41 -0700 (PDT)
Date: Wed, 27 Jun 2018 18:11:38 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 00/17] khwasan: kernel hardware assisted address
 sanitizer
Message-Id: <20180627181138.14c9b66e13b8778506205f89@linux-foundation.org>
In-Reply-To: <CAEZpscCcP6=O_OCqSwW8Y6u9Ee99SzWN+hRcgpP2tK=OEBFnNw@mail.gmail.com>
References: <cover.1530018818.git.andreyknvl@google.com>
	<20180627160800.3dc7f9ee41c0badbf7342520@linux-foundation.org>
	<CAN=P9pivApAo76Kjc0TUDE0kvJn0pET=47xU6e=ioZV2VqO0Rg@mail.gmail.com>
	<CAEZpscCcP6=O_OCqSwW8Y6u9Ee99SzWN+hRcgpP2tK=OEBFnNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vishwath Mohan <vishwath@google.com>
Cc: Kostya Serebryany <kcc@google.com>, andreyknvl@google.com, aryabinin@virtuozzo.com, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, catalin.marinas@arm.com, will.deacon@arm.com, cl@linux.com, mark.rutland@arm.com, Nick Desaulniers <ndesaulniers@google.com>, marc.zyngier@arm.com, dave.martin@arm.com, ard.biesheuvel@linaro.org, ebiederm@xmission.com, mingo@kernel.org, Paul Lawrence <paullawrence@google.com>, geert@linux-m68k.org, arnd@arndb.de, kirill.shutemov@linux.intel.com, gregkh@linuxfoundation.org, kstewart@linuxfoundation.org, rppt@linux.vnet.ibm.com, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Evgenii Stepanov <eugenis@google.com>, Lee.Smith@arm.com, Ramana.Radhakrishnan@arm.com, Jacob.Bramley@arm.com, Ruben.Ayrapetyan@arm.com, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, cpandya@codeaurora.org

On Wed, 27 Jun 2018 17:59:00 -0700 Vishwath Mohan <vishwath@google.com> wrote:

> > > > time consume much less memory, trading that off for somewhat imprecise
> > > > bug detection and being supported only for arm64.
> > >
> > > Why do we consider this to be a worthwhile change?
> > >
> > > Is KASAN's memory consumption actually a significant problem?  Some
> > > data regarding that would be very useful.
> >
> > On mobile, ASAN's and KASAN's memory usage is a significant problem.
> > Not sure if I can find scientific evidence of that.
> > CC-ing Vishwath Mohan who deals with KASAN on Android to provide
> > anecdotal evidence.
> >
> Yeah, I can confirm that it's an issue. Like Kostya mentioned, I don't have
> data on-hand, but anecdotally both ASAN and KASAN have proven problematic
> to enable for environments that don't tolerate the increased memory
> pressure well. This includes,
> (a) Low-memory form factors - Wear, TV, Things, lower-tier phones like Go
> (c) Connected components like Pixel's visual core
> <https://www.blog.google/products/pixel/pixel-visual-core-image-processing-and-machine-learning-pixel-2/>
> 
> 
> These are both places I'd love to have a low(er) memory footprint option at
> my disposal.

Thanks.

It really is important that such information be captured in the
changelogs.  In as much detail as can be mustered.
