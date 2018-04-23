Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C6CE06B000D
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 13:48:56 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b64so9519404pfl.13
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 10:48:56 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m11-v6si8438845pln.247.2018.04.23.10.48.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 Apr 2018 10:48:55 -0700 (PDT)
Date: Mon, 23 Apr 2018 19:48:50 +0200
From: Joerg Roedel <jroedel@suse.de>
Subject: Re: [PATCH 28/37] x86/mm/pti: Map kernel-text to user-space on 32
 bit kernels
Message-ID: <20180423174850.zjpx2mcs6dtfkgl3@suse.de>
References: <1524498460-25530-1-git-send-email-joro@8bytes.org>
 <1524498460-25530-29-git-send-email-joro@8bytes.org>
 <CAGXu5jKYhqvgooq8q-2NoMC_Cqh-SR8J0y0c1x9LteinDfQELQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jKYhqvgooq8q-2NoMC_Cqh-SR8J0y0c1x9LteinDfQELQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@google.com>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, Anthony Liguori <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>

On Mon, Apr 23, 2018 at 10:09:19AM -0700, Kees Cook wrote:
> On Mon, Apr 23, 2018 at 8:47 AM, Joerg Roedel <joro@8bytes.org> wrote:
> > From: Joerg Roedel <jroedel@suse.de>
> >
> > Keeping the kernel text mapped with G bit set keeps its
> > entries in the TLB across kernel entry/exit and improved the
> > performance. The 64 bit x86 kernels already do this when
> > there is no PCID, so do this in 32 bit as well since PCID is
> > not even supported there.
> 
> I think this should keep at least part of the logic as 64-bit since
> there are other reasons to turn off the Global flag:
> 
> https://lkml.kernel.org/r/20180420222026.D0B4AAC9@viggo.jf.intel.com

That patch you linked is for function pti_kernel_image_global_ok() which
is used on 32 bit too. So any logic implemented for 64 bit to turn off
the global bit will automatically be used on 32 bit.


Regards,

	Joerg
