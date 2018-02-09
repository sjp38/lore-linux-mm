Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 20AD96B0005
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 08:35:10 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id b193so3680507wmd.7
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 05:35:10 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id d46si1807995edb.88.2018.02.09.05.35.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Feb 2018 05:35:08 -0800 (PST)
Date: Fri, 9 Feb 2018 14:35:07 +0100
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 00/31 v2] PTI support for x86_32
Message-ID: <20180209133507.GD16484@8bytes.org>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
 <35f19c79-7277-3ad8-50bf-8def929377b6@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <35f19c79-7277-3ad8-50bf-8def929377b6@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juergen Gross <jgross@suse.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, jroedel@suse.de

Hi Juergen,

On Fri, Feb 09, 2018 at 01:11:42PM +0100, Juergen Gross wrote:
> On 09/02/18 10:25, Joerg Roedel wrote:
> > XENPV is also untested from my side, but I added checks to
> > not do the stack switches in the entry-code when XENPV is
> > enabled, so hopefully it works. But someone should test it,
> > of course.
> 
> That's unfortunate. 32 bit XENPV kernel is vulnerable to Meltdown, too.
> I'll have a look whether 32 bit XENPV is still working, though.
> 
> Adding support for KPTI with Xen PV should probably be done later. :-)

Not sure how much is missing to make it work there, one point is
certainly to write the right stack into tss.sp0 for xenpv on 32bit. This
write has a check to only happen for !xenpv.

But let's first test the code as-is on XENPV and see if it still boots
:)


Thanks,

	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
