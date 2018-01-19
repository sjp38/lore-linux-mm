Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7AE886B0268
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 04:57:07 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id p190so828581wmd.0
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 01:57:07 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id 92si1329026edn.468.2018.01.19.01.57.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jan 2018 01:57:06 -0800 (PST)
Date: Fri, 19 Jan 2018 10:57:05 +0100
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 03/16] x86/entry/32: Leave the kernel via the trampoline
 stack
Message-ID: <20180119095705.GZ28161@8bytes.org>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <1516120619-1159-4-git-send-email-joro@8bytes.org>
 <CALCETrW9F4QDFPG=ATs0QiyQO526SK0s==oYKhvVhxaYCw+65g@mail.gmail.com>
 <20180117092442.GJ28161@8bytes.org>
 <CAMzpN2j5EUh5TJDVWPPvL9Wn9LCcouCTjZ-CUuKRRo+rvsiH+g@mail.gmail.com>
 <20180117141006.GR28161@8bytes.org>
 <CALCETrVQitDeZATQDoZQ6TKxqT=QNWs-qytUp8edrMDxXBbxYw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrVQitDeZATQDoZQ6TKxqT=QNWs-qytUp8edrMDxXBbxYw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Brian Gerst <brgerst@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Joerg Roedel <jroedel@suse.de>

On Wed, Jan 17, 2018 at 10:12:32AM -0800, Andy Lutomirski wrote:
> I would optimize for simplicity, not speed.  You're already planning
> to write to CR3, which is serializing, blows away the TLB, *and* takes
> the absurdly large amount of time that the microcode needs to blow
> away the TLB.

Okay, so I am going to do the stack-switch before pt_regs is restored.
This is at least better than playing games with hiding the entry/exit
%esp somewhere in stack-memory.


Thanks,

	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
