Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id EE9156B027E
	for <linux-mm@kvack.org>; Sat, 14 Jul 2018 01:09:13 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f8-v6so7505320eds.6
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 22:09:13 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s35-v6si5509840edm.70.2018.07.13.22.09.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 22:09:12 -0700 (PDT)
Date: Sat, 14 Jul 2018 07:09:09 +0200
From: Joerg Roedel <jroedel@suse.de>
Subject: Re: [PATCH 39/39] x86/entry/32: Add debug code to check entry/exit
 cr3
Message-ID: <20180714050909.z4wohvvlbpaksbd5@suse.de>
References: <1531308586-29340-1-git-send-email-joro@8bytes.org>
 <1531308586-29340-40-git-send-email-joro@8bytes.org>
 <CALCETrUw5DTnPtDK5TUNv4z50rrmcxwPA-KqtBHcWRcazJXy6Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrUw5DTnPtDK5TUNv4z50rrmcxwPA-KqtBHcWRcazJXy6Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>

On Fri, Jul 13, 2018 at 10:28:50AM -0700, Andy Lutomirski wrote:
> On Wed, Jul 11, 2018 at 4:29 AM, Joerg Roedel <joro@8bytes.org> wrote:
> > From: Joerg Roedel <jroedel@suse.de>
> >
> > Add a config option that enabled code to check that we enter
> > and leave the kernel with the correct cr3. This is needed
> > because we have no NX protection of user-addresses in the
> > kernel-cr3 on x86-32 and wouldn't notice that type of bug
> > otherwise.
> >
> 
> I like this, but could you make it just use CONFIG_DEBUG_ENTRY?

Makes sense, I'll change it.


Regards,

	Joerg
