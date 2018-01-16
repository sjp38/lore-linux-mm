Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 36EEC6B0069
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 10:27:10 -0500 (EST)
Received: by mail-vk0-f69.google.com with SMTP id y127so1050462vkg.17
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 07:27:10 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id w51si2906558edb.141.2018.01.16.11.41.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 11:41:13 -0800 (PST)
Date: Tue, 16 Jan 2018 20:41:12 +0100
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 10/16] x86/mm/pti: Populate valid user pud entries
Message-ID: <20180116194112.GD28161@8bytes.org>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <1516120619-1159-11-git-send-email-joro@8bytes.org>
 <be22c252-3467-d14d-816b-023456604030@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <be22c252-3467-d14d-816b-023456604030@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, jroedel@suse.de

On Tue, Jan 16, 2018 at 10:06:48AM -0800, Dave Hansen wrote:
> On 01/16/2018 08:36 AM, Joerg Roedel wrote:
> > 
> > In PAE page-tables at the top-level most bits we usually set
> > with _KERNPG_TABLE are reserved, resulting in a #GP when
> > they are loaded by the processor.
> 
> Can you save me the trip to the SDM and remind me which bits actually
> cause trouble here?

Everything besides PRESENT, PCD, PWT and the actual physical address, so
RW, and NX for example cause a #GP.


	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
