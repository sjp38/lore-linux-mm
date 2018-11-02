Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id A5BDB6B0003
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 17:08:00 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id n5-v6so2865098pgv.6
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 14:08:00 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id bf10-v6si7329089plb.200.2018.11.02.14.07.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Nov 2018 14:07:59 -0700 (PDT)
Received: from mail-wm1-f42.google.com (mail-wm1-f42.google.com [209.85.128.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D8B2220831
	for <linux-mm@kvack.org>; Fri,  2 Nov 2018 21:07:58 +0000 (UTC)
Received: by mail-wm1-f42.google.com with SMTP id b203-v6so2952820wme.5
        for <linux-mm@kvack.org>; Fri, 02 Nov 2018 14:07:58 -0700 (PDT)
MIME-Version: 1.0
References: <20181026122856.66224-1-kirill.shutemov@linux.intel.com> <20181026122856.66224-2-kirill.shutemov@linux.intel.com>
In-Reply-To: <20181026122856.66224-2-kirill.shutemov@linux.intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 2 Nov 2018 14:07:44 -0700
Message-ID: <CALCETrXMA=4694sstXYWK1rSiHBAFbN=kPpB5PcG2uBpyxoF3g@mail.gmail.com>
Subject: Re: [PATCHv3 1/3] x86/mm: Move LDT remap out of KASLR region on
 5-level paging
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andrew Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Baoquan He <bhe@redhat.com>, Matthew Wilcox <willy@infradead.org>, X86 ML <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Oct 26, 2018 at 5:29 AM Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
>
> On 5-level paging LDT remap area is placed in the middle of
> KASLR randomization region and it can overlap with direct mapping,
> vmalloc or vmap area.
>
> Let's move LDT just before direct mapping which makes it safe for KASLR.
> This also allows us to unify layout between 4- and 5-level paging.
>
> We don't touch 4 pgd slot gap just before the direct mapping reserved
> for a hypervisor, but move direct mapping by one slot instead.
>
> The LDT mapping is per-mm, so we cannot move it into P4D page table next
> to CPU_ENTRY_AREA without complicating PGD table allocation for 5-level
> paging.

Reviewed-by: Andy Lutomirski <luto@kernel.org>

(assuming it passes tests with 4-level and 5-level.  my test setup is
current busted, and i'm bisecting it.)
