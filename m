Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2DDC96B0279
	for <linux-mm@kvack.org>; Fri,  7 Jul 2017 04:16:04 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id p135so38887101ita.11
        for <linux-mm@kvack.org>; Fri, 07 Jul 2017 01:16:04 -0700 (PDT)
Received: from mail-it0-x241.google.com (mail-it0-x241.google.com. [2607:f8b0:4001:c0b::241])
        by mx.google.com with ESMTPS id c92si2895200itd.67.2017.07.07.01.16.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jul 2017 01:16:02 -0700 (PDT)
Received: by mail-it0-x241.google.com with SMTP id k3so4288817ita.3
        for <linux-mm@kvack.org>; Fri, 07 Jul 2017 01:16:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170619232832.27116-4-dennisz@fb.com>
References: <20170619232832.27116-1-dennisz@fb.com> <20170619232832.27116-4-dennisz@fb.com>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Fri, 7 Jul 2017 10:16:01 +0200
Message-ID: <CAMuHMdWXR7tN01PArsSA5nwZV1GF=YgNdZuSeNq_ri1GoYSKCQ@mail.gmail.com>
Subject: Re: [PATCH 3/4] percpu: expose statistics about percpu memory via debugfs
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisz@fb.com>
Cc: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kernel-team@fb.com

Hi Dennis,

On Tue, Jun 20, 2017 at 1:28 AM, Dennis Zhou <dennisz@fb.com> wrote:
> There is limited visibility into the use of percpu memory leaving us
> unable to reason about correctness of parameters and overall use of
> percpu memory. These counters and statistics aim to help understand
> basic statistics about percpu memory such as number of allocations over
> the lifetime, allocation sizes, and fragmentation.
>
> New Config: PERCPU_STATS
>
> Signed-off-by: Dennis Zhou <dennisz@fb.com>
> ---
>  mm/Kconfig           |   8 ++
>  mm/Makefile          |   1 +
>  mm/percpu-internal.h | 131 ++++++++++++++++++++++++++++++
>  mm/percpu-km.c       |   4 +
>  mm/percpu-stats.c    | 222 +++++++++++++++++++++++++++++++++++++++++++++++++++
>  mm/percpu-vm.c       |   5 ++
>  mm/percpu.c          |   9 +++
>  7 files changed, 380 insertions(+)
>  create mode 100644 mm/percpu-stats.c
>
> diff --git a/mm/Kconfig b/mm/Kconfig
> index beb7a45..8fae426 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -706,3 +706,11 @@ config ARCH_USES_HIGH_VMA_FLAGS
>         bool
>  config ARCH_HAS_PKEYS
>         bool
> +
> +config PERCPU_STATS
> +       bool "Collect percpu memory statistics"
> +       default n
> +       help
> +         This feature collects and exposes statistics via debugfs. The
> +         information includes global and per chunk statistics, which can
> +         be used to help understand percpu memory usage.

Just wondering: does this option make sense to enable on !SMP?

If not, you may want to make it depend on SMP.

Thanks!

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
