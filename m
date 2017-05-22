Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 389C76B0292
	for <linux-mm@kvack.org>; Mon, 22 May 2017 19:42:13 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id o65so175626977oif.15
        for <linux-mm@kvack.org>; Mon, 22 May 2017 16:42:13 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id o186si2357418oib.257.2017.05.22.16.42.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 16:42:12 -0700 (PDT)
Received: from mail-ua0-f180.google.com (mail-ua0-f180.google.com [209.85.217.180])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id CA1B4239F1
	for <linux-mm@kvack.org>; Mon, 22 May 2017 23:42:11 +0000 (UTC)
Received: by mail-ua0-f180.google.com with SMTP id j17so68612072uag.3
        for <linux-mm@kvack.org>; Mon, 22 May 2017 16:42:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <519997CE-E94C-40E3-96A7-48CA682B553E@gmail.com>
References: <cover.1495492063.git.luto@kernel.org> <29e74164b213b349fd9c4bc1bec5e154af38ac87.1495492063.git.luto@kernel.org>
 <519997CE-E94C-40E3-96A7-48CA682B553E@gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 22 May 2017 16:41:50 -0700
Message-ID: <CALCETrV7_U-Noxho8WjwogBtHDs49pOujVKQze+4JtTQbiCRKQ@mail.gmail.com>
Subject: Re: [PATCH v2 10/11] x86/mm: Be more consistent wrt PAGE_SHIFT vs
 PAGE_SIZE in tlb flush code
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>, Arjan van de Ven <arjan@linux.intel.com>

On Mon, May 22, 2017 at 4:24 PM, Nadav Amit <nadav.amit@gmail.com> wrote:
>>
>>       /* Balance as user space task's flush, a bit conservative */
>>       if (end =3D=3D TLB_FLUSH_ALL ||
>> -         (end - start) > tlb_single_page_flush_ceiling * PAGE_SIZE) {
>> +         (end - start) > tlb_single_page_flush_ceiling >> PAGE_SHIFT) {
>
> Shouldn=E2=80=99t it be << ?

Gah, that's embarrassing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
