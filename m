Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C556E6B0003
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 06:24:35 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id s18-v6so5226355edr.15
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 03:24:35 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id a5-v6si1244039edl.388.2018.08.07.03.24.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Aug 2018 03:24:34 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 0/3] PTI for x86-32 Fixes
Date: Tue,  7 Aug 2018 12:24:28 +0200
Message-Id: <1533637471-30953-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de, joro@8bytes.org

Hi,

here is a small patch-set to fix two small issues in the
PTI implementation for 32 bit x86. The issues are:

	1) Fix the 32 bit PCID check. I used the wrong
	   operator there and this caused false-positive
	   warnings.

	2) The other two patches make sure the init-hole is
	   not mapped into the user page-table. It is the
	   32 bit counterpart to commit

	   c40a56a7818c ('x86/mm/init: Remove freed kernel image areas from alias mapping')

	   for the 64 bit PTI implementation.

I tested that no-PAE, PAE and 64 bit kernel all boot and
have correct user page-tables with identical global mappings
between user and kernel.

Regards,

	Joerg

Joerg Roedel (3):
  x86/mm/pti: Fix 32 bit PCID check
  x86/mm/pti: Don't clear permissions in pti_clone_pmd()
  x86/mm/pti: Clone kernel-image on PTE level for 32 bit

 arch/x86/mm/pti.c | 143 ++++++++++++++++++++++++++++++++++++++----------------
 1 file changed, 100 insertions(+), 43 deletions(-)

-- 
2.7.4
