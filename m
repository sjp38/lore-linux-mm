Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 77DA86B0003
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 15:00:08 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id w1-v6so20015417plq.8
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 12:00:08 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l192-v6si7606351pge.81.2018.07.13.12.00.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 12:00:06 -0700 (PDT)
Received: from mail-wr1-f51.google.com (mail-wr1-f51.google.com [209.85.221.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 51A17208B0
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 19:00:06 +0000 (UTC)
Received: by mail-wr1-f51.google.com with SMTP id h9-v6so26086018wro.3
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 12:00:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1531308586-29340-39-git-send-email-joro@8bytes.org>
References: <1531308586-29340-1-git-send-email-joro@8bytes.org> <1531308586-29340-39-git-send-email-joro@8bytes.org>
From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 13 Jul 2018 11:59:44 -0700
Message-ID: <CALCETrUTMwwKW6b3dubyC62Rk-_BTQN1zjFOYuLvS13EQ80p9A@mail.gmail.com>
Subject: Re: [PATCH 38/39] x86/mm/pti: Add Warning when booting on a PCID
 capable CPU
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>, Borislav Petkov <bp@alien8.de>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, Joerg Roedel <jroedel@suse.de>

On Wed, Jul 11, 2018 at 4:29 AM, Joerg Roedel <joro@8bytes.org> wrote:
> From: Joerg Roedel <jroedel@suse.de>
>
> Warn the user in case the performance can be significantly
> improved by switching to a 64-bit kernel.

...

> +#ifdef CONFIG_X86_32
> +       if (boot_cpu_has(X86_FEATURE_PCID)) {

I'm a bit confused. Wouldn't the setup_clear_cpu_cap() call in
early_identify_cpu() prevent this from working?

Boris, do we have a straightforward way to ask "does the CPU advertise
this feature in CPUID regardless of whether we have it enabled right
now"?

--Andy
