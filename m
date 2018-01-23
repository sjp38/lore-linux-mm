Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id DA8CE800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 09:39:23 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id z83so514997wmc.5
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 06:39:23 -0800 (PST)
Received: from fuzix.org (www.llwyncelyn.cymru. [82.70.14.225])
        by mx.google.com with ESMTPS id u6si374331wrb.183.2018.01.23.06.39.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jan 2018 06:39:22 -0800 (PST)
Date: Tue, 23 Jan 2018 14:38:31 +0000
From: Alan Cox <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [RFC PATCH 00/16] PTI support for x86-32
Message-ID: <20180123143831.2d769f9d@alans-desktop>
In-Reply-To: <aedcd5b4-f054-0579-d9e2-8439b982a5dd@zytor.com>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
	<5D89F55C-902A-4464-A64E-7157FF55FAD0@gmail.com>
	<886C924D-668F-4007-98CA-555DB6279E4F@gmail.com>
	<9CF1DD34-7C66-4F11-856D-B5E896988E16@gmail.com>
	<CA+55aFz4cUhqhmWg-F8NXGjowVGXkMA126H-mQ4n1A0ywtQ_tg@mail.gmail.com>
	<143DE376-A8A4-4A91-B4FF-E258D578242D@zytor.com>
	<CA+55aFxg5H38Ef4DUgMQ7KrsUtWdaKYKCRFZ8rangUrZ=OgCEw@mail.gmail.com>
	<aedcd5b4-f054-0579-d9e2-8439b982a5dd@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Nadav Amit <nadav.amit@gmail.com>, Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, "open
 list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Joerg Roedel <jroedel@suse.de>

> of timing requirements vs complexity.  At least theoretically one could
> imagine a machine which would take the trap after the speculative
> machine had already chased the pointer loop several levels down; this
> would most likely mean separate uops to allow for the existing
> out-of-order machine to do the bookkeeping.

It's not quite the same but in the IA-64 case you can write itanium code
that does exactly that. The speculation is expressed in software not
hardware (because you can trigger a load, then check later if it worked
out and respond appripriately).

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
