Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id C6FC46B0279
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 11:55:52 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id k68so2884867otc.5
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 08:55:52 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id s80si1786058oie.58.2017.06.06.08.55.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jun 2017 08:55:52 -0700 (PDT)
Received: from mail-vk0-f52.google.com (mail-vk0-f52.google.com [209.85.213.52])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 209A723A12
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 15:55:51 +0000 (UTC)
Received: by mail-vk0-f52.google.com with SMTP id g66so24827048vki.1
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 08:55:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170606131704.azzk62zsunynhj7o@gmail.com>
References: <cover.1495990440.git.luto@kernel.org> <20170606131704.azzk62zsunynhj7o@gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 6 Jun 2017 08:55:29 -0700
Message-ID: <CALCETrVYhbwJLHS_GB-C9ktt3oQ1boFcHa9Ax11OMxMRTPZvag@mail.gmail.com>
Subject: Re: [PATCH v4 0/8] x86 TLB flush cleanups, moving toward PCID support
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>

On Tue, Jun 6, 2017 at 6:17 AM, Ingo Molnar <mingo@kernel.org> wrote:
>
> FYI, there's this new build failure in rare randconfig variants:
>
> In file included from ./include/linux/mm.h:1032:0,
>                  from arch/x86/mm/tlb.c:3:
> arch/x86/mm/tlb.c: In function =E2=80=98flush_tlb_func_remote=E2=80=99:
> arch/x86/mm/tlb.c:251:21: error: =E2=80=98NR_TLB_REMOTE_FLUSH_RECEIVED=E2=
=80=99 undeclared (first
> use in this function)
>   count_vm_tlb_event(NR_TLB_REMOTE_FLUSH_RECEIVED);
>                      ^
> ./include/linux/vmstat.h:91:49: note: in definition of macro =E2=80=98cou=
nt_vm_tlb_event=E2=80=99
>  #define count_vm_tlb_event(x)    count_vm_event(x)
>                                                  ^
>
> Config attached.

This should be fixed by "[PATCH] vmstat: Make
NR_TLB_REMOTE_FLUSH_RECEIVED available even on UP", which I sent
yesterday.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
