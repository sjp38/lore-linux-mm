Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id EB8256B000D
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 14:00:14 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id u56-v6so19123168wrf.18
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 11:00:14 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d5si1216185edi.418.2018.04.23.11.00.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 Apr 2018 11:00:11 -0700 (PDT)
Date: Mon, 23 Apr 2018 20:00:09 +0200
From: Joerg Roedel <jroedel@suse.de>
Subject: Re: [PATCH 27/37] x86/mm/pti: Keep permissions when cloning kernel
 text in pti_clone_kernel_text()
Message-ID: <20180423180009.tubsdgxlmo56usq7@suse.de>
References: <1524498460-25530-1-git-send-email-joro@8bytes.org>
 <1524498460-25530-28-git-send-email-joro@8bytes.org>
 <CAGXu5jLN_rzmfgM-Xne836ip+qMc8T1QX=mhozo3NFLNssgUfw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jLN_rzmfgM-Xne836ip+qMc8T1QX=mhozo3NFLNssgUfw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@google.com>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, Anthony Liguori <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>

On Mon, Apr 23, 2018 at 10:06:20AM -0700, Kees Cook wrote:
> Why are there R/W text mappings in this range? I find that to be
> unexpected. Shouldn't CONFIG_DEBUG_WX already complain if that were
> true?

It actually complains, I have seen that with the base-kernel too. I
guess this is because of the different mark_rodata_ro() and
mark_nxdata_nx() implementations between 32 and 64 bit. They actually
protect different regions, I think one reason is that some regions are
not hupe-page aligned on 32 bit and doing the right protections as on 64
bit would require to split the 2M mappings into 4k mappings.

But I havn't looked deeper into that and whether it can be unified and
fixed for 32 bit. It is probably out-of-scope for this patch-set.


Regards,

	Joerg
