Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3BC556B005A
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 14:25:21 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id n11so2795755plp.13
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 11:25:21 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e12si1736855pgu.56.2018.02.09.11.25.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Feb 2018 11:25:20 -0800 (PST)
Date: Fri, 9 Feb 2018 20:25:15 +0100
From: Joerg Roedel <jroedel@suse.de>
Subject: Re: [PATCH 09/31] x86/entry/32: Leave the kernel via trampoline stack
Message-ID: <20180209192515.qvvixkn5rz77oz6l@suse.de>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
 <1518168340-9392-10-git-send-email-joro@8bytes.org>
 <CA+55aFzB9H=RT6YB3onZCephZMs9ccz4aJ_jcPcfEkKJD_YDCQ@mail.gmail.com>
 <20180209190226.lqh6twf7thfg52cq@suse.de>
 <CA+55aFzy6ZJDUpgHY0J2_z4kODaiYPgyHuOsMGiXmrhgR3kyPQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzy6ZJDUpgHY0J2_z4kODaiYPgyHuOsMGiXmrhgR3kyPQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>

On Fri, Feb 09, 2018 at 11:17:35AM -0800, Linus Torvalds wrote:
> Yeah, it's only true on the very latest uarchs, and even there it's
> not perfect for small copies.
> 
> On the older machines that are relevant for 32-bit code, it's often
> tens of cycles just for the ucode overhead, I think, and "rep movsb"
> actually does things literally a byte at a time.

Ugh, okay. So I switch to movsl, that should at least perform on-par
with the chain of 'pushl' instructions I had before.


Thanks,

	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
