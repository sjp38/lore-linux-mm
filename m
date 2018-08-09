Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8D1FB6B0007
	for <linux-mm@kvack.org>; Thu,  9 Aug 2018 07:16:08 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id z20-v6so1990806edq.10
        for <linux-mm@kvack.org>; Thu, 09 Aug 2018 04:16:08 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d4-v6si2516876edl.365.2018.08.09.04.16.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Aug 2018 04:16:07 -0700 (PDT)
Date: Thu, 9 Aug 2018 13:16:03 +0200
From: Joerg Roedel <jroedel@suse.de>
Subject: Re: [PATCH] x86/mm/pti: Move user W+X check into pti_finalize()
Message-ID: <20180809111603.aqon7xqmanvoycbu@suse.de>
References: <1533727000-9172-1-git-send-email-joro@8bytes.org>
 <aee38579-3a53-3370-b22b-04603b6b65ce@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <aee38579-3a53-3370-b22b-04603b6b65ce@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>

Hi Dave,

On Wed, Aug 08, 2018 at 08:54:37AM -0700, Dave Hansen wrote:
> One bit of information missing from the changelog: Could you clarify how
> there are any entries in the user page tables for the code to complain?
> Before pti_init(), I would have expected the user page tables to be empty.

The W+X check runs at the end of mark_readonly() in x86, which is after
pti_init() already put kernel mappings into the user page-table. Problem
is that the cloned entries are still W+X mapped, which is fixed in
pti_finalize() running _after_ mark_readonly().

Regards,

	Joerg
