Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 38D6B6B026C
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 16:44:53 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id l21-v6so14900442pff.3
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 13:44:53 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d4-v6sor6476901pgd.153.2018.07.12.13.44.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Jul 2018 13:44:52 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH 01/39] x86/asm-offsets: Move TSS_sp0 and TSS_sp1 to asm-offsets.c
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <1531308586-29340-2-git-send-email-joro@8bytes.org>
Date: Thu, 12 Jul 2018 13:44:49 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <29DEB3A0-223F-4C28-920B-0C1C918F2B56@amacapital.net>
References: <1531308586-29340-1-git-send-email-joro@8bytes.org> <1531308586-29340-2-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de


> On Jul 11, 2018, at 4:29 AM, Joerg Roedel <joro@8bytes.org> wrote:
>=20
> From: Joerg Roedel <jroedel@suse.de>
>=20
> These offsets will be used in 32 bit assembly code as well,
> so make them available for all of x86 code.

Reviewed-by: Andy Lutomirski <luto@kernel.org>

>=20
> Signed-off-by: Joerg Roedel <jroedel@suse.de>
> ---
> arch/x86/kernel/asm-offsets.c    | 4 ++++
> arch/x86/kernel/asm-offsets_64.c | 2 --
> 2 files changed, 4 insertions(+), 2 deletions(-)
>=20
> diff --git a/arch/x86/kernel/asm-offsets.c b/arch/x86/kernel/asm-offsets.c=

> index dcb008c..a1e1628 100644
> --- a/arch/x86/kernel/asm-offsets.c
> +++ b/arch/x86/kernel/asm-offsets.c
> @@ -103,4 +103,8 @@ void common(void) {
>    OFFSET(CPU_ENTRY_AREA_entry_trampoline, cpu_entry_area, entry_trampolin=
e);
>    OFFSET(CPU_ENTRY_AREA_entry_stack, cpu_entry_area, entry_stack_page);
>    DEFINE(SIZEOF_entry_stack, sizeof(struct entry_stack));
> +
> +    /* Offset for sp0 and sp1 into the tss_struct */
> +    OFFSET(TSS_sp0, tss_struct, x86_tss.sp0);
> +    OFFSET(TSS_sp1, tss_struct, x86_tss.sp1);
> }
> diff --git a/arch/x86/kernel/asm-offsets_64.c b/arch/x86/kernel/asm-offset=
s_64.c
> index b2dcd16..3b9405e 100644
> --- a/arch/x86/kernel/asm-offsets_64.c
> +++ b/arch/x86/kernel/asm-offsets_64.c
> @@ -65,8 +65,6 @@ int main(void)
> #undef ENTRY
>=20
>    OFFSET(TSS_ist, tss_struct, x86_tss.ist);
> -    OFFSET(TSS_sp0, tss_struct, x86_tss.sp0);
> -    OFFSET(TSS_sp1, tss_struct, x86_tss.sp1);
>    BLANK();
>=20
> #ifdef CONFIG_STACKPROTECTOR
> --=20
> 2.7.4
>=20
