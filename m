Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6FDDE6B0005
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 16:17:38 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id s8so1421283pgf.0
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 13:17:38 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t14si1678915pgc.92.2018.03.20.13.17.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 20 Mar 2018 13:17:36 -0700 (PDT)
Date: Tue, 20 Mar 2018 21:17:30 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: add config for readahead window
Message-ID: <20180320201730.xvvpc4gptqrn47ba@quack2.suse.cz>
References: <20180316182512.118361-1-wvw@google.com>
 <CAGXk5yoVMd9B=nvob7s=niCAQ9oHAX84eupF9Eet_dAk7WTStg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXk5yoVMd9B=nvob7s=niCAQ9oHAX84eupF9Eet_dAk7WTStg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wvw@google.com>
Cc: gregkh@linuxfoundation.org, Todd Poynor <toddpoynor@google.com>, Wei Wang <wei.vince.wang@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>, Ingo Molnar <mingo@kernel.org>, Sherry Cheung <SCheung@nvidia.com>, Oliver O'Halloran <oohall@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Huang Ying <ying.huang@intel.com>, Dennis Zhou <dennisz@fb.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de

On Fri 16-03-18 18:49:08, Wei Wang wrote:
> Android devices boot time benefits by bigger readahead window setting from
> init. This patch will make readahead window a config so early boot can benefit
> by it as well.
> 
> 
> On Fri, Mar 16, 2018 at 11:25 AM Wei Wang <wvw@google.com> wrote:
> 
>     From: Wei Wang <wvw@google.com>
> 
>     Change VM_MAX_READAHEAD value from the default 128KB to a configurable
>     value. This will allow the readahead window to grow to a maximum size
>     bigger than 128KB during boot, which could benefit to sequential read
>     throughput and thus boot performance.
> 
>     Signed-off-by: Wei Wang <wvw@google.com>

Just for record we had VM_MAX_READAHEAD changed to 512 in all SUSE
distributions for quite some years. But just recently we were re-evaluating
it and we are finding less and less reasons to keep this setting to 512 -
with newer storage benefits become marginal and the overhead of reading
more unnecessarily in some other corner cases is visible as well (I still
have somewhere reports from 0-day robot that complained to me about two
performance regressions coming from increased default readahead window).

So for your specific case it might make sense to increase the window when
you have a control of both the HW and the kernel but in general I tend to
currently agree with Linus & co. that the current default is probably fine.

I don't have a strong opinion on whether your ~90ms of boot time are good
enough justification for a kernel config option...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
