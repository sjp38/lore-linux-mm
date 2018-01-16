Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4E7F26B0287
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 14:31:37 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id b111so4364565wrd.16
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 11:31:37 -0800 (PST)
Received: from SMTP.EU.CITRIX.COM (smtp.ctxuk.citrix.com. [185.25.65.24])
        by mx.google.com with ESMTPS id p6si264118edh.215.2018.01.16.11.31.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 11:31:36 -0800 (PST)
Subject: Re: [RFC PATCH 00/16] PTI support for x86-32
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <CA+55aFx8V4JKfqZ+a9K355mopVYBBLNdx5Bh_oQuTGwdBFnoWg@mail.gmail.com>
From: Andrew Cooper <andrew.cooper3@citrix.com>
Message-ID: <aaa34988-84c4-a7cd-2c4d-f5e10ce8f289@citrix.com>
Date: Tue, 16 Jan 2018 19:21:00 +0000
MIME-Version: 1.0
In-Reply-To: <CA+55aFx8V4JKfqZ+a9K355mopVYBBLNdx5Bh_oQuTGwdBFnoWg@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Content-Language: en-GB
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H .
 Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Joerg Roedel <jroedel@suse.de>, Juergen Gross <JGross@suse.com>, Jan Beulich <JBeulich@suse.com>

On 16/01/18 18:59, Linus Torvalds wrote:
> On Tue, Jan 16, 2018 at 8:36 AM, Joerg Roedel <joro@8bytes.org> wrote:
>> One of the things that are surely broken is XEN_PV support.
>> I'd appreciate any help with testing and bugfixing on that
>> front.
> Xen PV and PTI don't work together even on x86-64 afaik, the Xen
> people apparently felt it wasn't worth it.  See the
>
>         if (hypervisor_is_type(X86_HYPER_XEN_PV)) {
>                 pti_print_if_insecure("disabled on XEN PV.");
>                 return;
>         }

64bit PV guests under Xen already have split pagetables.A  It is a base
and necessary part of the ABI, because segment limits stopped working in
64bit.

32bit PV guests aren't split, but by far the most efficient way of doing
this is to introduce a new enlightenment and have Xen switch all this
stuff (and IBRS, for that matter) on behalf of the guest kernel on
context switch.

~Andrew

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
