Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7B9C46B0026
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 14:11:15 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id q2so4421618pgf.22
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 11:11:15 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o5-v6si153419plh.780.2018.02.09.11.11.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Feb 2018 11:11:14 -0800 (PST)
Date: Fri, 9 Feb 2018 20:11:12 +0100
From: Joerg Roedel <jroedel@suse.de>
Subject: Re: [PATCH 00/31 v2] PTI support for x86_32
Message-ID: <20180209191112.55zyjf4njum75brd@suse.de>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
 <CALCETrUF61fqjXKG=kwf83JWpw=kgL16UvKowezDVwVA1=YVAw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrUF61fqjXKG=kwf83JWpw=kgL16UvKowezDVwVA1=YVAw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>

Hi Andy,

On Fri, Feb 09, 2018 at 05:47:43PM +0000, Andy Lutomirski wrote:
> One thing worth noting is that performance of this whole series is
> going to be abysmal due to the complete lack of 32-bit PCID.  Maybe
> any kernel built with this option set that runs on a CPU that has the
> PCID bit set in CPUID should print a big fat warning like "WARNING:
> you are using 32-bit PTI on a 64-bit PCID-capable CPU.  Your
> performance will increase dramatically if you switch to a 64-bit
> kernel."

Thanks for your review. I can add this warning, but I just hope that not
a lot of people will actually see it :)


	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
