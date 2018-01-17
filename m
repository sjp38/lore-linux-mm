Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id D74EA6B0033
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 09:45:20 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id 60so12498939otc.8
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 06:45:20 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r10si351404oib.100.2018.01.17.06.45.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jan 2018 06:45:19 -0800 (PST)
Date: Wed, 17 Jan 2018 08:45:03 -0600
From: Josh Poimboeuf <jpoimboe@redhat.com>
Subject: Re: [PATCH 03/16] x86/entry/32: Leave the kernel via the trampoline
 stack
Message-ID: <20180117144503.62e47m6e5yyyze3d@treble>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <1516120619-1159-4-git-send-email-joro@8bytes.org>
 <CALCETrW9F4QDFPG=ATs0QiyQO526SK0s==oYKhvVhxaYCw+65g@mail.gmail.com>
 <20180117092442.GJ28161@8bytes.org>
 <CAMzpN2j5EUh5TJDVWPPvL9Wn9LCcouCTjZ-CUuKRRo+rvsiH+g@mail.gmail.com>
 <CAMzpN2hXjHhx_9GDih8r808dYemYcy02f+LeXfG_8iuJkN82gA@mail.gmail.com>
 <20180117141418.GS28161@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20180117141418.GS28161@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Brian Gerst <brgerst@gmail.com>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Joerg Roedel <jroedel@suse.de>

On Wed, Jan 17, 2018 at 03:14:18PM +0100, Joerg Roedel wrote:
> On Wed, Jan 17, 2018 at 06:00:07AM -0800, Brian Gerst wrote:
> > On Wed, Jan 17, 2018 at 5:57 AM, Brian Gerst <brgerst@gmail.com> wrote:
> > But then again, you could take a fault on the trampoline stack if you
> > get a bad segment.  Perhaps just pushing the new stack pointer onto
> > the process stack before user segment loads will be the right move.
> 
> User segment loads pop from the stack, so having anything on-top also
> doesn't work.
> 
> Maybe I can leave some space at the bottom of the task-stack at entry
> time and store the pointer there on exit, if that doesn't confuse the
> stack unwinder too much.

If you put it at the end of the stack page, I _think_ all you'd have to
do is just adjust TOP_OF_KERNEL_STACK_PADDING.

-- 
Josh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
