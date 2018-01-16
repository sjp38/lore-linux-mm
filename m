Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4C90D6B029D
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 16:06:53 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id 31so1771935wri.9
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 13:06:53 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id o204si2402985wma.183.2018.01.16.13.06.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 16 Jan 2018 13:06:52 -0800 (PST)
Date: Tue, 16 Jan 2018 22:06:48 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 10/16] x86/mm/pti: Populate valid user pud entries
In-Reply-To: <1516120619-1159-11-git-send-email-joro@8bytes.org>
Message-ID: <alpine.DEB.2.20.1801162204000.2366@nanos>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org> <1516120619-1159-11-git-send-email-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, jroedel@suse.de

On Tue, 16 Jan 2018, Joerg Roedel wrote:

> From: Joerg Roedel <jroedel@suse.de>
> 
> With PAE paging we don't have PGD and P4D levels in the
> page-table, instead the PUD level is the highest one.
> 
> In PAE page-tables at the top-level most bits we usually set
> with _KERNPG_TABLE are reserved, resulting in a #GP when
> they are loaded by the processor.
> 
> Work around this by populating PUD entries in the user
> page-table only with _PAGE_PRESENT set.
> 
> I am pretty sure there is a cleaner way to do this, but
> until I find it use this #ifdef solution.

Stick somehting like

#define _KERNELPG_TABLE_PUD_ENTRY

into the 32 and 64 bit variants of some relevant header file 

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
