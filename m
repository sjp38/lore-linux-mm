Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4F4146B0033
	for <linux-mm@kvack.org>; Sat,  2 Dec 2017 13:49:43 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id f13so5863075oib.20
        for <linux-mm@kvack.org>; Sat, 02 Dec 2017 10:49:43 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r129sor1994792oig.266.2017.12.02.10.49.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 02 Dec 2017 10:49:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171202150554.GA30203@bombadil.infradead.org>
References: <20171202021626.26478-1-jhubbard@nvidia.com> <20171202150554.GA30203@bombadil.infradead.org>
From: Jann Horn <jannh@google.com>
Date: Sat, 2 Dec 2017 19:49:20 +0100
Message-ID: <CAG48ez2u3fjBDCMH4x3EUhG6ZD6VUa=A1p441P9fg=wUdzwHNQ@mail.gmail.com>
Subject: Re: [PATCH] mmap.2: MAP_FIXED is no longer discouraged
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: john.hubbard@gmail.com, Michael Kerrisk <mtk.manpages@gmail.com>, linux-man <linux-man@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, John Hubbard <jhubbard@nvidia.com>

On Sat, Dec 2, 2017 at 4:05 PM, Matthew Wilcox <willy@infradead.org> wrote:
> On Fri, Dec 01, 2017 at 06:16:26PM -0800, john.hubbard@gmail.com wrote:
>> MAP_FIXED has been widely used for a very long time, yet the man
>> page still claims that "the use of this option is discouraged".
>
> I think we should continue to discourage the use of this option, but
> I'm going to include some of your text in my replacement paragraph ...
>
> -Because requiring a fixed address for a mapping is less portable,
> -the use of this option is discouraged.
> +The use of this option is discouraged because it forcibly unmaps any
> +existing mapping at that address.  Programs which use this option need
> +to be aware that their memory map may change significantly from one run to
> +the next, depending on library versions, kernel versions and random numbers.

How about adding something explicit about when it's okay to use MAP_FIXED?
"This option should only be used to displace an existing mapping that is
controlled by the caller, or part of such a mapping." or something like that?

> +In a threaded process, checking the existing mappings can race against
> +a new dynamic library being loaded

malloc() and its various callers can also cause mmap() calls, which is probably
more relevant than library loading.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
