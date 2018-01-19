Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id B9EA76B0038
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 06:07:38 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id v17so221738pgb.18
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 03:07:38 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g66si8158639pgc.264.2018.01.19.03.07.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 19 Jan 2018 03:07:37 -0800 (PST)
Date: Fri, 19 Jan 2018 12:07:26 +0100
From: Joerg Roedel <jroedel@suse.de>
Subject: Re: [RFC PATCH 00/16] PTI support for x86-32
Message-ID: <20180119110726.odea3h3smcjyicnk@suse.de>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <20180119105527.GB29725@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180119105527.GB29725@amd>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>

Hey Pavel,

On Fri, Jan 19, 2018 at 11:55:28AM +0100, Pavel Machek wrote:
> Thanks for doing the work.
> 
> I tried applying it on top of -next, and that did not succeed. Let me
> try Linus tree...

Thanks for your help with testing this patch-set, but I recommend to
wait for the next version, as review already found a couple of bugs that
might crash your system. For example there are NMI cases that might
crash your machine because the NMI happens in kernel mode before the cr3
switch. VM86 mode is also definitly broken.

I am about to fix that and will send a new version, if all goes well, at
some point next week.


Thanks,

	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
