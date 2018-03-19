Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9DA726B0003
	for <linux-mm@kvack.org>; Sun, 18 Mar 2018 23:15:24 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l3so3279201wmc.3
        for <linux-mm@kvack.org>; Sun, 18 Mar 2018 20:15:24 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a24sor6314185edn.8.2018.03.18.20.15.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 18 Mar 2018 20:15:23 -0700 (PDT)
MIME-Version: 1.0
References: <20180316182512.118361-1-wvw@google.com> <CAGXk5yoVMd9B=nvob7s=niCAQ9oHAX84eupF9Eet_dAk7WTStg@mail.gmail.com>
 <87zi34zt85.fsf@yhuang-dev.intel.com>
In-Reply-To: <87zi34zt85.fsf@yhuang-dev.intel.com>
From: Wei Wang <wvw@google.com>
Date: Mon, 19 Mar 2018 03:15:11 +0000
Message-ID: <CAGXk5yrKw4edZs1pvrL5t67C1YASiOcZPsF3VDHmJ+nNQBVSqw@mail.gmail.com>
Subject: Re: [PATCH] mm: add config for readahead window
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Ying <ying.huang@intel.com>
Cc: gregkh@linuxfoundation.org, Todd Poynor <toddpoynor@google.com>, Wei Wang <wei.vince.wang@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>, Ingo Molnar <mingo@kernel.org>, Sherry Cheung <SCheung@nvidia.com>, Oliver O'Halloran <oohall@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Dennis Zhou <dennisz@fb.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Mar 18, 2018 at 7:37 PM Huang, Ying <ying.huang@intel.com> wrote:

> Wei Wang <wvw@google.com> writes:

> > Android devices boot time benefits by bigger readahead window setting
from
> > init. This patch will make readahead window a config so early boot can
> > benefit by it as well.

> Can you change the source code of init to call ioctl(BLKRASET) early?

> Best Regards,
> Huang, Ying

Yes, I am sure we can work this out by not touching it in mainline kernel.
One reason to bring it up again is that we found some SoC vendor has always
set a different value than default (128) in their kernel tree.

Thanks,
Wei Wang
