Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id AF2EB6B027C
	for <linux-mm@kvack.org>; Sat, 14 Jul 2018 01:08:31 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id s3-v6so2648916eds.15
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 22:08:31 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m46-v6si1815308edm.387.2018.07.13.22.08.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 22:08:30 -0700 (PDT)
Date: Sat, 14 Jul 2018 07:08:28 +0200
From: Joerg Roedel <jroedel@suse.de>
Subject: Re: [PATCH 38/39] x86/mm/pti: Add Warning when booting on a PCID
 capable CPU
Message-ID: <20180714050828.wl44vgwa7kzptsws@suse.de>
References: <1531308586-29340-1-git-send-email-joro@8bytes.org>
 <1531308586-29340-39-git-send-email-joro@8bytes.org>
 <CALCETrUTMwwKW6b3dubyC62Rk-_BTQN1zjFOYuLvS13EQ80p9A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrUTMwwKW6b3dubyC62Rk-_BTQN1zjFOYuLvS13EQ80p9A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Joerg Roedel <joro@8bytes.org>, Borislav Petkov <bp@alien8.de>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>

On Fri, Jul 13, 2018 at 11:59:44AM -0700, Andy Lutomirski wrote:
> On Wed, Jul 11, 2018 at 4:29 AM, Joerg Roedel <joro@8bytes.org> wrote:
> > From: Joerg Roedel <jroedel@suse.de>
> >
> > Warn the user in case the performance can be significantly
> > improved by switching to a 64-bit kernel.
> 
> ...
> 
> > +#ifdef CONFIG_X86_32
> > +       if (boot_cpu_has(X86_FEATURE_PCID)) {
> 
> I'm a bit confused. Wouldn't the setup_clear_cpu_cap() call in
> early_identify_cpu() prevent this from working?

Right you are, I don't have a PCID capable system at hand for testing,
so I didn't catch this...

> Boris, do we have a straightforward way to ask "does the CPU advertise
> this feature in CPUID regardless of whether we have it enabled right
> now"?

I guess we need to call cpuid again.


Regards,

	Joerg
