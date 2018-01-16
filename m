Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id CBE81280247
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 16:15:22 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id s22so1013633pfh.21
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 13:15:22 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id y20si2666775pfj.54.2018.01.16.13.15.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 13:15:21 -0800 (PST)
Subject: Re: [PATCH 12/16] x86/mm/pae: Populate the user page-table with user
 pgd's
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <1516120619-1159-13-git-send-email-joro@8bytes.org>
 <alpine.DEB.2.20.1801162207460.2366@nanos>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <d2e9dc79-24f0-842c-eaec-1c66bfd28ecb@intel.com>
Date: Tue, 16 Jan 2018 13:15:21 -0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1801162207460.2366@nanos>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Joerg Roedel <joro@8bytes.org>
Cc: Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, jroedel@suse.de

On 01/16/2018 01:10 PM, Thomas Gleixner wrote:
> 
> static inline pteval_t supported_pgd_mask(void)
> {
> 	if (IS_ENABLED(CONFIG_X86_64))
> 		return __supported_pte_mask;
> 	return __supported_pte_mask & ~_PAGE_NX);
> }
> 
> and get rid of the ifdeffery completely.

Heh, that's an entertaining way to do it.  Joerg, if you go do it this
way, it would be nice to add all the other gunk that we don't allow to
be set in the PAE pgd.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
