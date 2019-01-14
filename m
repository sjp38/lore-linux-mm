Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua1-f71.google.com (mail-ua1-f71.google.com [209.85.222.71])
	by kanga.kvack.org (Postfix) with ESMTP id 85E378E0002
	for <linux-mm@kvack.org>; Mon, 14 Jan 2019 09:03:04 -0500 (EST)
Received: by mail-ua1-f71.google.com with SMTP id c26so1522501uap.13
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 06:03:04 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e15sor322585vsa.13.2019.01.14.06.03.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 Jan 2019 06:03:03 -0800 (PST)
MIME-Version: 1.0
References: <20190114125903.24845-1-david@redhat.com> <20190114125903.24845-6-david@redhat.com>
In-Reply-To: <20190114125903.24845-6-david@redhat.com>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Mon, 14 Jan 2019 15:02:50 +0100
Message-ID: <CAMuHMdWEChb4+tf0m_qN9Mc6Am5T0rZLqAn6QsQ8NdMOCRPySQ@mail.gmail.com>
Subject: Re: [PATCH v2 5/9] m68k/mm: use __ClearPageReserved()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-riscv@lists.infradead.org, linux-s390 <linux-s390@vger.kernel.org>, linux-mediatek@lists.infradead.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>

On Mon, Jan 14, 2019 at 1:59 PM David Hildenbrand <david@redhat.com> wrote:
> The PG_reserved flag is cleared from memory that is part of the kernel
> image (and therefore marked as PG_reserved). Avoid using PG_reserved
> directly.
>
> Cc: Geert Uytterhoeven <geert@linux-m68k.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Matthew Wilcox <willy@infradead.org>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

BTW, it's a pity ctags doesn't know where __ClearPageReserved()
is defined.

Gr{oetje,eeting}s,

                        Geert


--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
