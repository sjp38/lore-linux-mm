Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4E2DC6B0038
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 17:12:48 -0500 (EST)
Received: by mail-ua0-f198.google.com with SMTP id h30so3173290uac.1
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 14:12:48 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h125sor1006626vkg.253.2017.11.29.14.12.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 Nov 2017 14:12:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171129144219.22867-1-mhocko@kernel.org>
References: <20171129144219.22867-1-mhocko@kernel.org>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 29 Nov 2017 14:12:45 -0800
Message-ID: <CAGXu5jKxgkar3802JYUqrVF==h99hDH9UUdZSgH9T_-n9y22EA@mail.gmail.com>
Subject: Re: [PATCH 0/2] mm: introduce MAP_FIXED_SAFE
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Linux API <linux-api@vger.kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Joel Stanley <joel@jms.id.au>, Michal Hocko <mhocko@suse.com>

On Wed, Nov 29, 2017 at 6:42 AM, Michal Hocko <mhocko@kernel.org> wrote:
> Except we won't export expose the new semantic to the userspace at all.

I'm confused: the changes in patch 1 are explicitly adding
MAP_FIXED_SAFE to the uapi. If it's not supposed to be exposed,
shouldn't it go somewhere else?

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
