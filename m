Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9EABD6B0003
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 04:10:51 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id n14so603673wmc.0
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 01:10:51 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id o11si3680987edc.29.2018.03.02.01.10.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Mar 2018 01:10:50 -0800 (PST)
Date: Fri, 2 Mar 2018 10:10:49 +0100
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 12/31] x86/entry/32: Add PTI cr3 switch to non-NMI
 entry/exit points
Message-ID: <20180302091049.GP16484@8bytes.org>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
 <1518168340-9392-13-git-send-email-joro@8bytes.org>
 <afd5bae9-f53e-a225-58f1-4ba2422044e3@redhat.com>
 <20180301133430.wda4qesqhxnww7d6@8bytes.org>
 <2ae8b01f-844b-b8b1-3198-5db70c3e083b@redhat.com>
 <20180301165019.kuynvb6fkcwdpxjx@suse.de>
 <CAMzpN2gxVnb65LHXbBioM4LAMN2d-d1-xx3QyQrmsHECBXC29g@mail.gmail.com>
 <CA+55aFynSZgf1wnWrweODJiRw5hLkUPzFF7T8QJ7vBo=zWTfqw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFynSZgf1wnWrweODJiRw5hLkUPzFF7T8QJ7vBo=zWTfqw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Brian Gerst <brgerst@gmail.com>, Joerg Roedel <jroedel@suse.de>, Waiman Long <longman@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>

On Thu, Mar 01, 2018 at 10:38:21AM -0800, Linus Torvalds wrote:
> Note that debug traps can happen regardless of TF, Think kgdb etc.
> Arguably kgdb users get what they deserve, but still.. I think root
> can set kernel breakpoints too.

But that seems to be broken right now at least wrt. to the espfix code
where there is no handling for in the #DB handler. Can userspace really
set arbitrary kernel breakpoints?


	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
