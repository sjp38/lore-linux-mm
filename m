Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C284F6B0029
	for <linux-mm@kvack.org>; Fri, 26 Jan 2018 07:36:23 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id j13so250592wmh.3
        for <linux-mm@kvack.org>; Fri, 26 Jan 2018 04:36:23 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id 5si1357509edb.158.2018.01.26.04.36.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jan 2018 04:36:18 -0800 (PST)
Date: Fri, 26 Jan 2018 13:36:16 +0100
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [RFC PATCH 00/16] PTI support for x86-32
Message-ID: <20180126123616.GK28161@8bytes.org>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <5D89F55C-902A-4464-A64E-7157FF55FAD0@gmail.com>
 <886C924D-668F-4007-98CA-555DB6279E4F@gmail.com>
 <9CF1DD34-7C66-4F11-856D-B5E896988E16@gmail.com>
 <20180122085625.GE28161@8bytes.org>
 <20180125170925.1d72d587@alans-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180125170925.1d72d587@alans-desktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alan Cox <gnomes@lxorguk.ukuu.org.uk>
Cc: Nadav Amit <nadav.amit@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, jroedel@suse.de

Hi Alan,

On Thu, Jan 25, 2018 at 05:09:25PM +0000, Alan Cox wrote:
> On Mon, 22 Jan 2018 09:56:25 +0100
> Joerg Roedel <joro@8bytes.org> wrote:
> 
> > Hey Nadav,
> > 
> > On Sun, Jan 21, 2018 at 03:46:24PM -0800, Nadav Amit wrote:
> > > It does seem that segmentation provides sufficient protection from Meltdown.  
> > 
> > Thanks for testing this, if this turns out to be true for all affected
> > uarchs it would be a great and better way of protection than enabling
> > PTI.
> > 
> > But I'd like an official statement from Intel on that one, as their
> > recommended fix is still to use PTI.
> 
> It is: we don't think segmentation works on all processors as a defence.

Thanks for checking and the official statement. So the official
mitigation recommendation is still to use PTI.


Regards,

	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
