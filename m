Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id BD9A2800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 09:57:59 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id c142so558296wmh.4
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 06:57:59 -0800 (PST)
Received: from fuzix.org (www.llwyncelyn.cymru. [82.70.14.225])
        by mx.google.com with ESMTPS id 3si6677053wmc.56.2018.01.23.06.57.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jan 2018 06:57:58 -0800 (PST)
Date: Tue, 23 Jan 2018 14:57:17 +0000
From: Alan Cox <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [RFC PATCH 00/16] PTI support for x86-32
Message-ID: <20180123145717.75c84e9a@alans-desktop>
In-Reply-To: <20180122085625.GE28161@8bytes.org>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
	<5D89F55C-902A-4464-A64E-7157FF55FAD0@gmail.com>
	<886C924D-668F-4007-98CA-555DB6279E4F@gmail.com>
	<9CF1DD34-7C66-4F11-856D-B5E896988E16@gmail.com>
	<20180122085625.GE28161@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Nadav Amit <nadav.amit@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, jroedel@suse.de

On Mon, 22 Jan 2018 09:56:25 +0100
Joerg Roedel <joro@8bytes.org> wrote:

> Hey Nadav,
> 
> On Sun, Jan 21, 2018 at 03:46:24PM -0800, Nadav Amit wrote:
> > It does seem that segmentation provides sufficient protection from Meltdown.  
> 
> Thanks for testing this, if this turns out to be true for all affected
> uarchs it would be a great and better way of protection than enabling
> PTI.
> 
> But I'd like an official statement from Intel on that one, as their
> recommended fix is still to use PTI.
> 
> And as you said, if it turns out that this works only on some Intel
> uarchs, we can also detect it at runtime and then chose the fasted
> meltdown protection mechanism.

I'll follow this up and get an official statement.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
