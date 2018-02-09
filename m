Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 62CBB6B0023
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 14:09:20 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id z2so4413892pgu.18
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 11:09:20 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z8-v6si1887631plo.762.2018.02.09.11.09.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Feb 2018 11:09:19 -0800 (PST)
Date: Fri, 9 Feb 2018 20:09:15 +0100
From: Joerg Roedel <jroedel@suse.de>
Subject: Re: [PATCH 20/31] x86/mm/pae: Populate the user page-table with user
 pgd's
Message-ID: <20180209190915.tevittkx5d3ngnyr@suse.de>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
 <1518168340-9392-21-git-send-email-joro@8bytes.org>
 <CALCETrUgk3s0uDZrHqy-HjudFXLeWN=oKz6EH9i-NCdWQEnAqw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrUgk3s0uDZrHqy-HjudFXLeWN=oKz6EH9i-NCdWQEnAqw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>

On Fri, Feb 09, 2018 at 05:48:36PM +0000, Andy Lutomirski wrote:
> Can you rename the helper from pti_set_user_pgd() to
> pti_set_user_top_level_entry() or similar?  The name was already a bit
> absurd, but now it's just nuts.

Sure, I can do that, just pti_set_user_top_level_entry() is a bit long.
I try to find a shorter name.


Thanks,

	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
