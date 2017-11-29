Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9F63E6B0253
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 17:25:38 -0500 (EST)
Received: by mail-vk0-f69.google.com with SMTP id w136so1491423vkd.14
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 14:25:38 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y1sor1095172uae.297.2017.11.29.14.25.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 Nov 2017 14:25:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171129144219.22867-1-mhocko@kernel.org>
References: <20171129144219.22867-1-mhocko@kernel.org>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 29 Nov 2017 14:25:36 -0800
Message-ID: <CAGXu5jLa=b2HhjWXXTQunaZuz11qUhm5aNXHpS26jVqb=G-gfw@mail.gmail.com>
Subject: Re: [PATCH 0/2] mm: introduce MAP_FIXED_SAFE
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Linux API <linux-api@vger.kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Florian Weimer <fweimer@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Joel Stanley <joel@jms.id.au>, Michal Hocko <mhocko@suse.com>

On Wed, Nov 29, 2017 at 6:42 AM, Michal Hocko <mhocko@kernel.org> wrote:
> The first patch introduced MAP_FIXED_SAFE which enforces the given
> address but unlike MAP_FIXED it fails with ENOMEM if the given range
> conflicts with an existing one. The flag is introduced as a completely

I still think this name should be better. "SAFE" doesn't say what it's
safe from...

MAP_FIXED_UNIQUE
MAP_FIXED_ONCE
MAP_FIXED_FRESH

?

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
