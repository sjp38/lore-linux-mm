Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5DAAE6B0012
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 13:51:17 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id u68so77207wmd.5
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 10:51:17 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id b9si1368067wrh.124.2018.03.27.10.51.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 27 Mar 2018 10:51:16 -0700 (PDT)
Date: Tue, 27 Mar 2018 19:51:07 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 00/11] Use global pages with PTI
In-Reply-To: <c0e7ca0b-dcb5-66e2-9df6-f53e4eb22781@linux.intel.com>
Message-ID: <alpine.DEB.2.21.1803271949250.1618@nanos.tec.linutronix.de>
References: <20180323174447.55F35636@viggo.jf.intel.com> <CA+55aFwEC1O+6qRc35XwpcuLSgJ+0GP6ciqw_1Oc-msX=efLvQ@mail.gmail.com> <be2e683c-bf0a-e9ce-2f02-4905f6bd56d3@linux.intel.com> <alpine.DEB.2.21.1803271526260.1964@nanos.tec.linutronix.de>
 <c0e7ca0b-dcb5-66e2-9df6-f53e4eb22781@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, =?ISO-8859-15?Q?J=FCrgen_Gro=DF?= <jgross@suse.com>, the arch/x86 maintainers <x86@kernel.org>, namit@vmware.com

On Tue, 27 Mar 2018, Dave Hansen wrote:

> On 03/27/2018 06:36 AM, Thomas Gleixner wrote:
> >>                         User Time       Kernel Time     Clock Elapsed
> >> Baseline ( 0 GLB PTEs)  803.79          67.77           237.30
> >> w/series (28 GLB PTEs)  807.70 (+0.7%)  68.07 (+0.7%)   238.07 (+0.3%)
> >>
> >> Without PCIDs, it behaves the way I would expect.
> > What's the performance benefit on !PCID systems? And I mean systems which
> > actually do not have PCID, not a PCID system with 'nopcid' on the command
> > line.
> 
> Do you have something in mind for this?  Basically *all* of the servers
> that I have access to have PCID because they are newer than ~7 years old.
> 
> That leaves *some* Ivybridge and earlier desktops, Atoms and AMD

AMD is not interesting as it's not PTI and uses GLOBAL anyway.

> systems.  Atoms are going to be the easiest thing to get my hands on,
> but I tend to shy away from them for performance work.

What I have in mind is that I wonder whether the whole circus is worth it
when there is no performance advantage on PCID systems.

Thanks,

	tglx
