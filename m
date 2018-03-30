Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 566056B0010
	for <linux-mm@kvack.org>; Fri, 30 Mar 2018 08:09:25 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id c1so4045565wri.22
        for <linux-mm@kvack.org>; Fri, 30 Mar 2018 05:09:25 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i30sor3893893wra.37.2018.03.30.05.09.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 30 Mar 2018 05:09:23 -0700 (PDT)
Date: Fri, 30 Mar 2018 14:09:20 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 00/11] Use global pages with PTI
Message-ID: <20180330120920.btobga44wqytlkoe@gmail.com>
References: <20180323174447.55F35636@viggo.jf.intel.com>
 <CA+55aFwEC1O+6qRc35XwpcuLSgJ+0GP6ciqw_1Oc-msX=efLvQ@mail.gmail.com>
 <be2e683c-bf0a-e9ce-2f02-4905f6bd56d3@linux.intel.com>
 <alpine.DEB.2.21.1803271526260.1964@nanos.tec.linutronix.de>
 <c0e7ca0b-dcb5-66e2-9df6-f53e4eb22781@linux.intel.com>
 <alpine.DEB.2.21.1803271949250.1618@nanos.tec.linutronix.de>
 <20180327200719.lvdomez6hszpmo4s@gmail.com>
 <0d6ea030-ec3b-d649-bad7-89ff54094e25@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0d6ea030-ec3b-d649-bad7-89ff54094e25@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, =?iso-8859-1?Q?J=FCrgen_Gro=DF?= <jgross@suse.com>, the arch/x86 maintainers <x86@kernel.org>, namit@vmware.com


* Dave Hansen <dave.hansen@linux.intel.com> wrote:

> On 03/27/2018 01:07 PM, Ingo Molnar wrote:
> > * Thomas Gleixner <tglx@linutronix.de> wrote:
> >>> systems.  Atoms are going to be the easiest thing to get my hands on,
> >>> but I tend to shy away from them for performance work.
> >> What I have in mind is that I wonder whether the whole circus is worth it
> >> when there is no performance advantage on PCID systems.
> 
> I was waiting on trying to find a relatively recent Atom system (they
> actually come in reasonably sized servers [1]), but I'm hitting a snag
> there, so I figured I'd just share a kernel compile using Ingo's
> perf-based methodology on a Skylake desktop system with PCIDs.
>
> Here's the kernel compile:
> 
> No Global pages (baseline): 186.951 seconds time elapsed  ( +-  0.35% )
> 28 Global pages (this set): 185.756 seconds time elapsed  ( +-  0.09% )
>                              -1.195 seconds (-0.64%)
> 
> Lower is better here, obviously.
> 
> I also re-checked everything using will-it-scale's llseek1 test[2] which
> is basically a microbenchmark of a halfway reasonable syscall.  Higher
> here is better.
> 
> No Global pages (baseline): 15783951 lseeks/sec
> 28 Global pages (this set): 16054688 lseeks/sec
> 			     +270737 lseeks/sec (+1.71%)
> 
> So, both the kernel compile and the microbenchmark got measurably faster.

Ok, cool, this is much better!

Mind re-sending the patch-set against latest -tip so it can be merged?

At this point !PCID Intel hardware is not a primary concern, if something bad 
happens on them with global pages we can quirk global pages off on them in some 
way, or so.

Thanks,

	Ingo
