Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f199.google.com (mail-ig0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0B9346B007E
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 13:24:39 -0400 (EDT)
Received: by mail-ig0-f199.google.com with SMTP id lp2so62321178igb.3
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 10:24:39 -0700 (PDT)
Received: from mail-oi0-x22b.google.com (mail-oi0-x22b.google.com. [2607:f8b0:4003:c06::22b])
        by mx.google.com with ESMTPS id 62si3478105ots.136.2016.06.09.10.24.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jun 2016 10:24:38 -0700 (PDT)
Received: by mail-oi0-x22b.google.com with SMTP id p204so74077333oih.3
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 10:24:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <8D80C93B-3DD6-469B-90D6-FBC71B917EAD@gmail.com>
References: <cover.1452294700.git.luto@kernel.org> <95a853538da28c64dfc877c60549ec79ed7a5d69.1452294700.git.luto@kernel.org>
 <8D80C93B-3DD6-469B-90D6-FBC71B917EAD@gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 9 Jun 2016 10:24:18 -0700
Message-ID: <CALCETrX1TJ0BBJ40Gu_TNrrdntLdeR42Erg4QMbt5HoN9DqngA@mail.gmail.com>
Subject: Re: [RFC 05/13] x86/mm: Add barriers and document switch_mm-vs-flush synchronization
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Jun 3, 2016 at 10:42 AM, Nadav Amit <nadav.amit@gmail.com> wrote:
> Following this patch, if (current->active_mm !=3D mm), flush_tlb_page() s=
till
> doesn=E2=80=99t call smp_mb() before checking mm_cpumask(mm).
>
> In contrast, flush_tlb_mm_range() does call smp_mb().
>
> Is there a reason for this discrepancy?

Not that I can remember.  Is the remote flush case likely to be racy?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
