Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7220B6B0294
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 14:55:45 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id h1so11417754wre.20
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 11:55:45 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id h2si2689332edf.540.2018.01.16.11.55.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 11:55:44 -0800 (PST)
Date: Tue, 16 Jan 2018 20:55:43 +0100
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [RFC PATCH 00/16] PTI support for x86-32
Message-ID: <20180116195543.GG28161@8bytes.org>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <CA+55aFx8V4JKfqZ+a9K355mopVYBBLNdx5Bh_oQuTGwdBFnoWg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFx8V4JKfqZ+a9K355mopVYBBLNdx5Bh_oQuTGwdBFnoWg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Joerg Roedel <jroedel@suse.de>

Hi Linus,

On Tue, Jan 16, 2018 at 10:59:01AM -0800, Linus Torvalds wrote:
> Yes, I'm very happy to see that this is actually not nearly as bad as
> I feared it might be,

Yeah, I was looking at the original PTI patches and my impression was
that a lot of the complicated stuff (like setting up the cpu_entry_area)
was already in there for 32 bit too. So it was mostly about the entry
code and some changes to the 32bit page-table code.

> Some of those #ifdef's in the PTI code you added might want more
> commentary about what the exact differences are. And maybe they could
> be done more cleanly with some abstraction. But nothing looked
> _horrible_.

I'll add more comments and better abstraction, Dave has already
suggested some improvements here. Reading some of my comments again,
they need a rework anyway.

> .. and please run all the segment and syscall selfchecks that Andy has written.

Didn't know about them yet, thanks. I will run them too in my testing

> Xen PV and PTI don't work together even on x86-64 afaik, the Xen
> people apparently felt it wasn't worth it.  See the
> 
>         if (hypervisor_is_type(X86_HYPER_XEN_PV)) {
>                 pti_print_if_insecure("disabled on XEN PV.");
>                 return;
>         }
> 
> in pti_check_boottime_disable().

But I might have broken something for them anyway, honestly I didn't pay
much attention to the XEN_PV case as I was trying to get it running
here. My hope is that someone who knows Xen better than I do will help
out :)


Regards,

	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
