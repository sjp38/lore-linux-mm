Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4538B6B0038
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 04:02:10 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id j3so7291691pfh.16
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 01:02:10 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id h34si4661933pld.202.2017.12.15.01.02.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 15 Dec 2017 01:02:09 -0800 (PST)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH v2 0/2] mm: introduce MAP_FIXED_SAFE
In-Reply-To: <CAGXu5jKjjsyYJTWTqzO0mQKM+9mCH=jY_x90wJpoXbsDcLSv+Q@mail.gmail.com>
References: <20171213092550.2774-1-mhocko@kernel.org> <CAGXu5jKjjsyYJTWTqzO0mQKM+9mCH=jY_x90wJpoXbsDcLSv+Q@mail.gmail.com>
Date: Fri, 15 Dec 2017 20:02:04 +1100
Message-ID: <876098ictv.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Michal Hocko <mhocko@kernel.org>
Cc: Linux API <linux-api@vger.kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Joel Stanley <joel@jms.id.au>, Michal Hocko <mhocko@suse.com>

Kees Cook <keescook@chromium.org> writes:

> On Wed, Dec 13, 2017 at 1:25 AM, Michal Hocko <mhocko@kernel.org> wrote:
>>
>> Hi,
>> I am resending with some minor updates based on Michael's review and
>> ask for inclusion. There haven't been any fundamental objections for
>> the RFC [1] nor the previous version [2].  The biggest discussion
>> revolved around the naming. There were many suggestions flowing
>> around MAP_REQUIRED, MAP_EXACT, MAP_FIXED_NOCLOBBER, MAP_AT_ADDR,
>> MAP_FIXED_NOREPLACE etc...
>
> With this named MAP_FIXED_NOREPLACE (the best consensus we've got on a
> name), please consider this series:
>
> Acked-by: Kees Cook <keescook@chromium.org>

I don't feel like I'm actually qualified to ack the mm and binfmt
changes, but everything *looks* correct to me, and you've fixed the flag
numbering such that it can go in mman-common.h as I suggested.

So if the name was MAP_FIXED_NOREPLACE I would also be happy with it.

Acked-by: Michael Ellerman <mpe@ellerman.id.au>

I can resubmit with the name changed if that's what it takes.

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
