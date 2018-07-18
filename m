Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 40E3E6B000A
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 07:59:11 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b25-v6so1820056eds.17
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 04:59:11 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id 7-v6si447864edh.451.2018.07.18.04.59.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 04:59:06 -0700 (PDT)
Date: Wed, 18 Jul 2018 13:59:05 +0200
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 10/39] x86/entry/32: Handle Entry from Kernel-Mode on
 Entry-Stack
Message-ID: <20180718115905.GA18541@8bytes.org>
References: <1531308586-29340-1-git-send-email-joro@8bytes.org>
 <1531308586-29340-11-git-send-email-joro@8bytes.org>
 <CALCETrUg_4q8a2Tt_Z+GtVuBwj3Ct3=j7M-YhiK06=XjxOG82A@mail.gmail.com>
 <20180714052110.cobtew6rms23ih37@suse.de>
 <7AB4F269-E0E8-4290-A764-69D8605467E8@amacapital.net>
 <20180714080159.hqp36q7fxzb2ktlq@suse.de>
 <75BDF04F-9585-438C-AE04-918FBE00A174@amacapital.net>
 <20180717071545.ojdall7tatbjtfai@suse.de>
 <CALCETrXAF6+mkDL4+uQdHQdJ=G70YVu_k55P_x6Mgi4hXe3oYw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrXAF6+mkDL4+uQdHQdJ=G70YVu_k55P_x6Mgi4hXe3oYw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Joerg Roedel <jroedel@suse.de>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>

On Tue, Jul 17, 2018 at 01:06:11PM -0700, Andy Lutomirski wrote:
> Yes, we obviously need to restore the correct cr3.  But I really don't
> like the code that rewrites the stack frame that we're about to IRET
> to, especially when it doesn't seem to serve a purpose.  I'd much
> rather the code just get its CR3 right and do the IRET and trust that
> the frame it's returning to is still there.

Okay, I'll give it a try and if it works without the copying we can put
that on-top of this patch-set. This also has the benefit that we can
revert it later if it causes problems down the road.


Regards,

	Joerg
