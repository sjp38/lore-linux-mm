Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8BF696B0271
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 16:11:54 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id c188so9214507ith.7
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 13:11:54 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t1sor2110309itg.106.2018.02.09.13.11.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Feb 2018 13:11:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180209210918.GA7333@amd>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
 <CALCETrUF61fqjXKG=kwf83JWpw=kgL16UvKowezDVwVA1=YVAw@mail.gmail.com> <20180209210918.GA7333@amd>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 9 Feb 2018 13:11:52 -0800
Message-ID: <CA+55aFy7sme11ok4FqZD2upvF+4g3sDK-yQakNnD1LAsALDOUQ@mail.gmail.com>
Subject: Re: [PATCH 00/31 v2] PTI support for x86_32
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Andy Lutomirski <luto@kernel.org>, Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Joerg Roedel <jroedel@suse.de>

On Fri, Feb 9, 2018 at 1:09 PM, Pavel Machek <pavel@ucw.cz> wrote:
>
> Hardware supports PCID even on 32-bit kernels, no?

We're not adding support for it even if it were possible. No way.

Christ, even if you want to run 32-bit user code, you'd better run a
64-bit kernel. Backporting the PCID bits to something that no actual
real developer will ever use is crazy and unacceptable.

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
