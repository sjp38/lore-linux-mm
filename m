Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id BF5B36B0003
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 03:08:23 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id y13-v6so8402858iop.3
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 00:08:23 -0700 (PDT)
Received: from torfep01.bell.net (simcoe207srvr.owm.bell.net. [184.150.200.207])
        by mx.google.com with ESMTPS id v126-v6si6891867iod.82.2018.07.30.00.08.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 30 Jul 2018 00:08:20 -0700 (PDT)
Received: from bell.net torfep01 184.150.200.158 by torfep01.bell.net
          with ESMTP
          id <20180730070820.HGLT3030.torfep01.bell.net@torspm02.bell.net>
          for <linux-mm@kvack.org>; Mon, 30 Jul 2018 03:08:20 -0400
Message-ID: <2bc48efc86800949761b8f4d3a165a9f9c25c57e.camel@sympatico.ca>
Subject: Re: [PATCH 0/3] PTI x86-32 Updates and Fixes
From: "David H. Gutteridge" <dhgutteridge@sympatico.ca>
Date: Mon, 30 Jul 2018 03:08:14 -0400
In-Reply-To: <1532533683-5988-1-git-send-email-joro@8bytes.org>
References: <1532533683-5988-1-git-send-email-joro@8bytes.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, jroedel@suse.de, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>

On Wed, 2018-07-25 at 17:48 +0200, Joerg Roedel wrote:
> Hi,
> 
> here are three patches on-top of tip/x86/pti to update the
> vmallo_fault() fix and also with another important fix.
> 
> The first two patches remove the WARN_ON_ONCE(in_nmi) from
> the vmalloc_fault() function and revert the previous fix, as
> discussed at the last patch-set.
> 
> The third patch is an important fix for a silent memory
> corruption issue found by the trinity fuzzer, which did take
> a while to track down. But I found it and with the fix the
> fuzzer already runs for couple of hours now and the VM is
> still alive.
> 
> Regards,
> 
> 	Joerg
> 
> Joerg Roedel (3):
>   x86/mm: Remove in_nmi() warning from vmalloc_fault()
>   Revert "perf/core: Make sure the ring-buffer is mapped in all
>     page-tables"
>   x86/kexec: Allocate 8k PGDs for PTI
> 
>  arch/x86/kernel/machine_kexec_32.c |  5 +++--
>  arch/x86/mm/fault.c                |  2 --
>  kernel/events/ring_buffer.c        | 16 ----------------
>  3 files changed, 3 insertions(+), 20 deletions(-)

Hi Joerg,

I've found no significant issues in my testing of this patch set.
The only minor thing I noted is that in your previous "v8" patch set
([PATCH 38/39] x86/mm/pti: Add Warning when booting on a PCID capable
CPU), it reports the warning on non-PCID capable CPUs: I think you
intended a bitwise "&", not a logical "&&" in the if statement?

Tested-by: David H. Gutteridge <dhgutteridge@sympatico.ca>

Regards,

Dave
