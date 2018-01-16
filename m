Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 610B26B0069
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 12:31:45 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id m4so15405003iob.16
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 09:31:45 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id z5si2467901itd.105.2018.01.16.09.31.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 16 Jan 2018 09:31:44 -0800 (PST)
Date: Tue, 16 Jan 2018 18:31:15 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 06/16] x86/mm/ldt: Reserve high address-space range for
 the LDT
Message-ID: <20180116173115.GG2228@hirez.programming.kicks-ass.net>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <1516120619-1159-7-git-send-email-joro@8bytes.org>
 <20180116165213.GF2228@hirez.programming.kicks-ass.net>
 <20180116171343.GB28161@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180116171343.GB28161@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, jroedel@suse.de

On Tue, Jan 16, 2018 at 06:13:43PM +0100, Joerg Roedel wrote:
> Hi Peter,
> 
> On Tue, Jan 16, 2018 at 05:52:13PM +0100, Peter Zijlstra wrote:
> > On Tue, Jan 16, 2018 at 05:36:49PM +0100, Joerg Roedel wrote:
> > > From: Joerg Roedel <jroedel@suse.de>
> > > 
> > > Reserve 2MB/4MB of address space for mapping the LDT to
> > > user-space.
> > 
> > LDT is 64k, we need 2 per CPU, and NR_CPUS <= 64 on 32bit, that gives
> > 64K*2*64=8M > 2M.
> 
> Thanks, I'll fix that in the next version.

Just lower the max SMP setting until it fits or something. 32bit is too
address space starved for lots of CPU in any case, 64 CPUs on 32bit is
absolutely insane.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
