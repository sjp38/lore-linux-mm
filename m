Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B31096B0006
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 11:50:26 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id o11so2841038pgp.14
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 08:50:26 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k67si3255410pfj.298.2018.03.01.08.50.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Mar 2018 08:50:25 -0800 (PST)
Date: Thu, 1 Mar 2018 17:50:19 +0100
From: Joerg Roedel <jroedel@suse.de>
Subject: Re: [PATCH 12/31] x86/entry/32: Add PTI cr3 switch to non-NMI
 entry/exit points
Message-ID: <20180301165019.kuynvb6fkcwdpxjx@suse.de>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
 <1518168340-9392-13-git-send-email-joro@8bytes.org>
 <afd5bae9-f53e-a225-58f1-4ba2422044e3@redhat.com>
 <20180301133430.wda4qesqhxnww7d6@8bytes.org>
 <2ae8b01f-844b-b8b1-3198-5db70c3e083b@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2ae8b01f-844b-b8b1-3198-5db70c3e083b@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>

On Thu, Mar 01, 2018 at 09:33:11AM -0500, Waiman Long wrote:
> On 03/01/2018 08:34 AM, Joerg Roedel wrote:
> I think that should fix the issue of debug exception from userspace.
> 
> One thing that I am not certain about is whether debug exception can
> happen even if the IF flag is cleared. If it can, debug exception should
> be handled like NMI as the state of the CR3 can be indeterminate if the
> exception happens in the entry/exit code.

I am actually not 100% sure where it can happen, from the code it can
happen from anywhere, except when we are running on an espfix stack.

So I am not sure we need the same complex handling NMIs need wrt. to
switching the cr3s.


	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
