Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 680426B0025
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 16:55:51 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id q6so2644700pgv.12
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 13:55:51 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d8si5592449pgt.246.2018.03.16.13.55.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 13:55:50 -0700 (PDT)
Received: from mail-io0-f180.google.com (mail-io0-f180.google.com [209.85.223.180])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id B41BC2183B
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 20:55:49 +0000 (UTC)
Received: by mail-io0-f180.google.com with SMTP id h23so14123957iob.11
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 13:55:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180302091049.GP16484@8bytes.org>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
 <1518168340-9392-13-git-send-email-joro@8bytes.org> <afd5bae9-f53e-a225-58f1-4ba2422044e3@redhat.com>
 <20180301133430.wda4qesqhxnww7d6@8bytes.org> <2ae8b01f-844b-b8b1-3198-5db70c3e083b@redhat.com>
 <20180301165019.kuynvb6fkcwdpxjx@suse.de> <CAMzpN2gxVnb65LHXbBioM4LAMN2d-d1-xx3QyQrmsHECBXC29g@mail.gmail.com>
 <CA+55aFynSZgf1wnWrweODJiRw5hLkUPzFF7T8QJ7vBo=zWTfqw@mail.gmail.com> <20180302091049.GP16484@8bytes.org>
From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 16 Mar 2018 20:55:28 +0000
Message-ID: <CALCETrXt9Wc1YVO=v=+J9XaZPOX=wwUJiM30UK59_uBL1arG3w@mail.gmail.com>
Subject: Re: [PATCH 12/31] x86/entry/32: Add PTI cr3 switch to non-NMI
 entry/exit points
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Brian Gerst <brgerst@gmail.com>, Joerg Roedel <jroedel@suse.de>, Waiman Long <longman@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>

On Fri, Mar 2, 2018 at 9:10 AM, Joerg Roedel <joro@8bytes.org> wrote:
> On Thu, Mar 01, 2018 at 10:38:21AM -0800, Linus Torvalds wrote:
>> Note that debug traps can happen regardless of TF, Think kgdb etc.
>> Arguably kgdb users get what they deserve, but still.. I think root
>> can set kernel breakpoints too.
>
> But that seems to be broken right now at least wrt. to the espfix code
> where there is no handling for in the #DB handler. Can userspace really
> set arbitrary kernel breakpoints?
>

As far as I'm concerned, I don't try to support kernel debugger users
setting arbitrary breakpoints in the kernel entry text.
