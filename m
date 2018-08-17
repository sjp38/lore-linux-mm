Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id D6E236B05E6
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 22:44:49 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id c5-v6so5684793ioi.13
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 19:44:49 -0700 (PDT)
Received: from mtlfep01.bell.net (belmont79srvr.owm.bell.net. [184.150.200.79])
        by mx.google.com with ESMTPS id m15-v6si606257iob.70.2018.08.16.19.44.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Aug 2018 19:44:48 -0700 (PDT)
Received: from bell.net mtlfep01 184.150.200.30 by mtlfep01.bell.net
          with ESMTP
          id <20180817024448.VBN10498.mtlfep01.bell.net@mtlspm02.bell.net>
          for <linux-mm@kvack.org>; Thu, 16 Aug 2018 22:44:48 -0400
Message-ID: <0055c50937cff963e243bba815947cfcdd8b3d0b.camel@sympatico.ca>
Subject: Re: [PATCH 0/3] PTI for x86-32 Fixes
From: "David H. Gutteridge" <dhgutteridge@sympatico.ca>
Date: Thu, 16 Aug 2018 22:44:47 -0400
In-Reply-To: <1533637471-30953-1-git-send-email-joro@8bytes.org>
References: <1533637471-30953-1-git-send-email-joro@8bytes.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, jroedel@suse.de

On Tue, 2018-08-07 at 12:24 +0200, Joerg Roedel wrote:
> Hi,
> 
> here is a small patch-set to fix two small issues in the
> PTI implementation for 32 bit x86. The issues are:
> 
> 	1) Fix the 32 bit PCID check. I used the wrong
> 	   operator there and this caused false-positive
> 	   warnings.
> 
> 	2) The other two patches make sure the init-hole is
> 	   not mapped into the user page-table. It is the
> 	   32 bit counterpart to commit
> 
> 	   c40a56a7818c ('x86/mm/init: Remove freed kernel image areas
> from alias mapping')
> 
> 	   for the 64 bit PTI implementation.
> 
> I tested that no-PAE, PAE and 64 bit kernel all boot and
> have correct user page-tables with identical global mappings
> between user and kernel.
> 
> Regards,
> 
> 	Joerg
> 
> Joerg Roedel (3):
>   x86/mm/pti: Fix 32 bit PCID check
>   x86/mm/pti: Don't clear permissions in pti_clone_pmd()
>   x86/mm/pti: Clone kernel-image on PTE level for 32 bit
> 
>  arch/x86/mm/pti.c | 143 ++++++++++++++++++++++++++++++++++++++-------
> ---------
>  1 file changed, 100 insertions(+), 43 deletions(-)

I've tested this in a VM and on an Atom laptop, as usual. No
regressions noted.

Tested-by: David H. Gutteridge <dhgutteridge@sympatico.ca>

Regards,

Dave
