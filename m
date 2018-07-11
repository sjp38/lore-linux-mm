Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 936186B0003
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 13:28:35 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f8-v6so4420890eds.6
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 10:28:35 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x17-v6si362718edl.345.2018.07.11.10.28.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 10:28:34 -0700 (PDT)
Date: Wed, 11 Jul 2018 19:28:30 +0200 (CEST)
From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH 00/39 v7] PTI support for x86-32
In-Reply-To: <CA+55aFzrG+GV5ySVUiiod8Va5P0_vmUuh25Pner1r7c_aQgH9g@mail.gmail.com>
Message-ID: <nycvar.YFH.7.76.1807111923420.997@cbobk.fhfr.pm>
References: <1531308586-29340-1-git-send-email-joro@8bytes.org> <CA+55aFzrG+GV5ySVUiiod8Va5P0_vmUuh25Pner1r7c_aQgH9g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, =?ISO-8859-15?Q?J=FCrgen_Gro=DF?= <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, Joerg Roedel <jroedel@suse.de>

On Wed, 11 Jul 2018, Linus Torvalds wrote:

> It's the testing that worries me most. Pretty much no developers run 
> 32-bit any more, and I'd be most worried about the odd interactions that 
> might be hw-specific. Some crazy EFI mapping setup or the similar odd 
> case that simply requires a particular configuration or setup.
> 
> But I guess those issues will never be found until we just spring this
> all on the unsuspecting public.

FWIW we shipped Joerg's 32bit KAISER kernel out to our 32bit users (on old 
product where we still support it) on Apr 25th already (and some issues 
have been identified since then because of that). So it (or its port to 
3.0, to be more precise :p) already did receive some crowd-testing.

-- 
Jiri Kosina
SUSE Labs
