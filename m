Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id A4A946B002C
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 14:17:37 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id u4so8980768iti.2
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 11:17:37 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d70sor1950595itd.148.2018.02.09.11.17.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 09 Feb 2018 11:17:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180209190226.lqh6twf7thfg52cq@suse.de>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
 <1518168340-9392-10-git-send-email-joro@8bytes.org> <CA+55aFzB9H=RT6YB3onZCephZMs9ccz4aJ_jcPcfEkKJD_YDCQ@mail.gmail.com>
 <20180209190226.lqh6twf7thfg52cq@suse.de>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 9 Feb 2018 11:17:35 -0800
Message-ID: <CA+55aFzy6ZJDUpgHY0J2_z4kODaiYPgyHuOsMGiXmrhgR3kyPQ@mail.gmail.com>
Subject: Re: [PATCH 09/31] x86/entry/32: Leave the kernel via trampoline stack
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <jroedel@suse.de>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>

On Fri, Feb 9, 2018 at 11:02 AM, Joerg Roedel <jroedel@suse.de> wrote:
>
> Okay, I used movsb because I remembered that being the recommendation
> for the most efficient memcpy, and it safes me an instruction. But that
> is probably only true on modern CPUs.

Yeah, it's only true on the very latest uarchs, and even there it's
not perfect for small copies.

On the older machines that are relevant for 32-bit code, it's often
tens of cycles just for the ucode overhead, I think, and "rep movsb"
actually does things literally a byte at a time.

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
