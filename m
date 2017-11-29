Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 08BE16B0038
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 17:15:25 -0500 (EST)
Received: by mail-ua0-f199.google.com with SMTP id k6so3097263uab.21
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 14:15:25 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v27sor985425uae.75.2017.11.29.14.15.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 Nov 2017 14:15:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <b154b794-7a8b-995e-0954-9234b9446b31@prevas.dk>
References: <20171129144219.22867-1-mhocko@kernel.org> <b154b794-7a8b-995e-0954-9234b9446b31@prevas.dk>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 29 Nov 2017 14:15:22 -0800
Message-ID: <CAGXu5j+ShPrCuzGpGYap4dgU7=rEXQJtMEtPHWmSGjzysqSezQ@mail.gmail.com>
Subject: Re: [PATCH 0/2] mm: introduce MAP_FIXED_SAFE
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <rasmus.villemoes@prevas.dk>
Cc: Michal Hocko <mhocko@kernel.org>, Linux API <linux-api@vger.kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Joel Stanley <joel@jms.id.au>, Michal Hocko <mhocko@suse.com>

On Wed, Nov 29, 2017 at 7:13 AM, Rasmus Villemoes
<rasmus.villemoes@prevas.dk> wrote:
> On 2017-11-29 15:42, Michal Hocko wrote:
>>
>> The first patch introduced MAP_FIXED_SAFE which enforces the given
>> address but unlike MAP_FIXED it fails with ENOMEM if the given range
>> conflicts with an existing one.
>
> [s/ENOMEM/EEXIST/, as it seems you also did in the actual patch and
> changelog]
>
>>The flag is introduced as a completely
>> new one rather than a MAP_FIXED extension because of the backward
>> compatibility. We really want a never-clobber semantic even on older
>> kernels which do not recognize the flag. Unfortunately mmap sucks wrt.
>> flags evaluation because we do not EINVAL on unknown flags. On those
>> kernels we would simply use the traditional hint based semantic so the
>> caller can still get a different address (which sucks) but at least not
>> silently corrupt an existing mapping. I do not see a good way around
>> that.
>
> I think it would be nice if this rationale was in the 1/2 changelog,
> along with the hint about what userspace that wants to be compatible
> with old kernels will have to do (namely, check that it got what it
> requested) - which I see you did put in the man page.

Okay, so ignore my other email, I must have misunderstood. It _is_,
quite intentionally, being exposed to userspace. Cool by me. :)

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
