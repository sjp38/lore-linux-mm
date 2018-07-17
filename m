Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8D6676B0010
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 03:07:30 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id az8-v6so44129plb.15
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 00:07:30 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h11-v6si222560pgf.558.2018.07.17.00.07.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 00:07:29 -0700 (PDT)
Date: Tue, 17 Jul 2018 09:07:25 +0200
From: Joerg Roedel <jroedel@suse.de>
Subject: Re: [PATCH 07/39] x86/entry/32: Enter the kernel via trampoline stack
Message-ID: <20180717070725.paxlewuu4z4qd3cu@suse.de>
References: <1531308586-29340-1-git-send-email-joro@8bytes.org>
 <1531308586-29340-8-git-send-email-joro@8bytes.org>
 <A66D58A6-3DC6-4CF3-B2A5-433C6E974060@amacapital.net>
 <20180713105620.z6bjhqzfez2hll6r@8bytes.org>
 <CALCETrW4XMD9TSTxK3h-3p5ZE5Z=DupiUBtiXnMmSprbXtJr3g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrW4XMD9TSTxK3h-3p5ZE5Z=DupiUBtiXnMmSprbXtJr3g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>

On Fri, Jul 13, 2018 at 10:21:39AM -0700, Andy Lutomirski wrote:
> On Fri, Jul 13, 2018 at 3:56 AM, Joerg Roedel <joro@8bytes.org> wrote:
> > Right, I implement a more restrictive check.
> 
> But the check needs to be correct or we'll mess up, right?  I think
> the code will be much more robust and easier to review if you check
> "on the entry stack" instead of ">= the entry stack".  (Or <= -- I can
> never remember how this works in AT&T syntax.)

Yeah, I re-used the check implemented on the NMI entry path, it checks
exactly for the entry-stack range.


Regards,

	Joerg
