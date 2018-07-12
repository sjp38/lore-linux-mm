Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id D9DE66B026B
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 16:44:11 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id cf17-v6so10551035plb.2
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 13:44:11 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g12-v6sor7454206pla.36.2018.07.12.13.44.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Jul 2018 13:44:10 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH 02/39] x86/entry/32: Rename TSS_sysenter_sp0 to TSS_entry_stack
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <1531308586-29340-3-git-send-email-joro@8bytes.org>
Date: Thu, 12 Jul 2018 13:44:07 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <2FB5A671-8497-4A55-B0E9-082FA4259D1D@amacapital.net>
References: <1531308586-29340-1-git-send-email-joro@8bytes.org> <1531308586-29340-3-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de



> On Jul 11, 2018, at 4:29 AM, Joerg Roedel <joro@8bytes.org> wrote:
>=20
> From: Joerg Roedel <jroedel@suse.de>
>=20
> The stack address doesn't need to be stored in tss.sp0 if
> we switch manually like on sysenter. Rename the offset so
> that it still makes sense when we change its location.
>=20
> We will also use this stack for all kernel-entry points, not
> just sysenter. Reflect that in the name as well.

Reviewed-by: Andy Lutomirski <luto@kernel.org>

But, if there=E2=80=99s another version, please fix this comment:

>=20
>=20
>=20
>    /* Offset from the sysenter stack to tss.sp0 */

Here

> -    DEFINE(TSS_sysenter_sp0, offsetof(struct cpu_entry_area, tss.x86_tss.=
sp0) -
> +    DEFINE(TSS_entry_stack, offsetof(struct cpu_entry_area, tss.x86_tss.s=
p0) -
>           offsetofend(struct cpu_entry_area, entry_stack_page.stack));
>=20
> #ifdef CONFIG_STACKPROTECTOR
> --=20
> 2.7.4
>=20
