Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6B40E6B000D
	for <linux-mm@kvack.org>; Thu,  9 Aug 2018 07:26:42 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id bb5-v6so3523376plb.13
        for <linux-mm@kvack.org>; Thu, 09 Aug 2018 04:26:42 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v18-v6si6901189pgh.162.2018.08.09.04.26.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Aug 2018 04:26:41 -0700 (PDT)
Date: Thu, 9 Aug 2018 13:26:35 +0200
From: Joerg Roedel <jroedel@suse.de>
Subject: Re: [PATCH] x86/mm/pti: Move user W+X check into pti_finalize()
Message-ID: <20180809112635.5nafpey7c2nowir7@suse.de>
References: <1533727000-9172-1-git-send-email-joro@8bytes.org>
 <CAGXu5jK-wd=wbXcqoaogThVF1gHvH+UXgvVtsFuV2efjo8K46g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jK-wd=wbXcqoaogThVF1gHvH+UXgvVtsFuV2efjo8K46g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@google.com>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, Anthony Liguori <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>

Hi Kees,

On Wed, Aug 08, 2018 at 01:33:01PM -0700, Kees Cook wrote:
> I'm slightly nervous about complicating this and splitting up the
> check. I have a mild preference that all the checks get moved later,
> so that all architectures have the checks happening at the same time
> during boot. Splitting this up could give us some weird differences
> between architectures, etc.

As fas as I can see the checks are implemented on x86, arm, and arm64. I
agree that it would be better to run the checks at a unified place
across architectures and can send a patch-set for set once the dust
around the 32-bit PTI implementation for x86 has settled.

But currently the call-places are architecture specific and with that in
mind the split-up on x86 is the right thing to do. I'll change that back
when I implement your idea above.

Regards,

	Joerg
