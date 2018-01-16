Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id CCC836B0271
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 13:06:55 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id j26so12282082pff.8
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 10:06:55 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id w23si2283138pfk.337.2018.01.16.10.06.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 10:06:54 -0800 (PST)
Subject: Re: [PATCH 10/16] x86/mm/pti: Populate valid user pud entries
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <1516120619-1159-11-git-send-email-joro@8bytes.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <be22c252-3467-d14d-816b-023456604030@intel.com>
Date: Tue, 16 Jan 2018 10:06:48 -0800
MIME-Version: 1.0
In-Reply-To: <1516120619-1159-11-git-send-email-joro@8bytes.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, jroedel@suse.de

On 01/16/2018 08:36 AM, Joerg Roedel wrote:
> 
> In PAE page-tables at the top-level most bits we usually set
> with _KERNPG_TABLE are reserved, resulting in a #GP when
> they are loaded by the processor.

Can you save me the trip to the SDM and remind me which bits actually
cause trouble here?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
