Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id A130F6B0027
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 17:26:49 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id p203-v6so2698211itc.1
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 14:26:49 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 82sor3481584itg.101.2018.03.16.14.26.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Mar 2018 14:26:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180316205607.lr6nmrkkzzbw2tqh@node.shutemov.name>
References: <20180316182512.118361-1-wvw@google.com> <20180316205607.lr6nmrkkzzbw2tqh@node.shutemov.name>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 16 Mar 2018 14:26:47 -0700
Message-ID: <CA+55aFyLRhWZ-XD72xkZZm0FshhspK1RJezGfMo-7YPVGXweHA@mail.gmail.com>
Subject: Re: [PATCH] mm: add config for readahead window
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Wei Wang <wvw@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, toddpoynor@google.com, wei.vince.wang@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>, Ingo Molnar <mingo@kernel.org>, Sherry Cheung <SCheung@nvidia.com>, Oliver O'Halloran <oohall@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Huang Ying <ying.huang@intel.com>, Dennis Zhou <dennisz@fb.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Mar 16, 2018 at 1:56 PM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
>
> Increase of readahead window was proposed several times. And rejected.
> IIRC, Linus was against it.

I have never seen any valid situation that wasn't tuning for one odd
machine, usually with a horribly crappy disk setup and very little
testing of latencies or low-memory situations.

And "horribly crappy" very much tends to include "big serious
enterprise hardware" that people paid big bucks for, and that has huge
theoretical throughput for large transfers, but is pure garbage in
every other way.

So I'm still very much inclined against these kinds of things. They
need *extensive* numbers and explanations for why it's not just some
uncommon thing for one setup.

                   Linus
