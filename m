Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 178BF6B0006
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 11:48:19 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id r9-v6so3276124edh.14
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 08:48:19 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id f12-v6si6846451edq.89.2018.07.25.08.48.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jul 2018 08:48:17 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 0/3] PTI x86-32 Updates and Fixes
Date: Wed, 25 Jul 2018 17:48:00 +0200
Message-Id: <1532533683-5988-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>, joro@8bytes.org

Hi,

here are three patches on-top of tip/x86/pti to update the
vmallo_fault() fix and also with another important fix.

The first two patches remove the WARN_ON_ONCE(in_nmi) from
the vmalloc_fault() function and revert the previous fix, as
discussed at the last patch-set.

The third patch is an important fix for a silent memory
corruption issue found by the trinity fuzzer, which did take
a while to track down. But I found it and with the fix the
fuzzer already runs for couple of hours now and the VM is
still alive.

Regards,

	Joerg

Joerg Roedel (3):
  x86/mm: Remove in_nmi() warning from vmalloc_fault()
  Revert "perf/core: Make sure the ring-buffer is mapped in all
    page-tables"
  x86/kexec: Allocate 8k PGDs for PTI

 arch/x86/kernel/machine_kexec_32.c |  5 +++--
 arch/x86/mm/fault.c                |  2 --
 kernel/events/ring_buffer.c        | 16 ----------------
 3 files changed, 3 insertions(+), 20 deletions(-)

-- 
2.7.4
