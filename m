Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id DDB286B0005
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 19:26:21 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id y7-v6so1846717plh.7
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 16:26:21 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id g76si2092866pfa.337.2018.04.18.16.26.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Apr 2018 16:26:20 -0700 (PDT)
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH 03/35] x86/entry/32: Load task stack from x86_tss.sp1 in SYSENTER handler
References: <1523892323-14741-1-git-send-email-joro@8bytes.org>
	<1523892323-14741-4-git-send-email-joro@8bytes.org>
Date: Wed, 18 Apr 2018 16:26:19 -0700
In-Reply-To: <1523892323-14741-4-git-send-email-joro@8bytes.org> (Joerg
	Roedel's message of "Mon, 16 Apr 2018 17:24:51 +0200")
Message-ID: <87k1t4t7tw.fsf@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waim@linux.intel.com

Joerg Roedel <joro@8bytes.org> writes:

> From: Joerg Roedel <jroedel@suse.de>
>
> We want x86_tss.sp0 point to the entry stack later to use
> it as a trampoline stack for other kernel entry points
> besides SYSENTER.
>
> So store the task stack pointer in x86_tss.sp1, which is
> otherwise unused by the hardware, as Linux doesn't make use
> of Ring 1.

Seems like a hack. Why can't that be stored in a per cpu variable?

-Andi
