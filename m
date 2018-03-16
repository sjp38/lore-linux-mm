Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 313C16B0010
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 18:13:32 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id m78so1356535wma.7
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 15:13:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z11sor4197822edh.50.2018.03.16.15.13.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Mar 2018 15:13:30 -0700 (PDT)
MIME-Version: 1.0
References: <20180316182512.118361-1-wvw@google.com> <20180316143306.dd98055a170497e9535cc176@linux-foundation.org>
 <CAMFybE7EKyJMmR=Ntn1UX1ZMWJ=32v9G_kYdXh4LhinDv_JO8Q@mail.gmail.com> <20180316145942.9e2d353ed10041fbac42e5a3@linux-foundation.org>
In-Reply-To: <20180316145942.9e2d353ed10041fbac42e5a3@linux-foundation.org>
From: Wei Wang <wvw@google.com>
Date: Fri, 16 Mar 2018 22:13:19 +0000
Message-ID: <CAGXk5yoL=NuW1d1VHD9_CXi3kg0gmKeWFubNC7Ro053yDnR9vA@mail.gmail.com>
Subject: Re: [PATCH] mm: add config for readahead window
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wei Wang <wei.vince.wang@gmail.com>, gregkh@linuxfoundation.org, Todd Poynor <toddpoynor@google.com>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>, Ingo Molnar <mingo@kernel.org>, Sherry Cheung <SCheung@nvidia.com>, Oliver O'Halloran <oohall@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Huang Ying <ying.huang@intel.com>, Dennis Zhou <dennisz@fb.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Mar 16, 2018 at 2:59 PM Andrew Morton <akpm@linux-foundation.org>
wrote:

> On Fri, 16 Mar 2018 21:51:48 +0000 Wei Wang <wei.vince.wang@gmail.com>
wrote:

> > On Fri, Mar 16, 2018, 14:33 Andrew Morton <akpm@linux-foundation.org>
wrote:
> >
> > > On Fri, 16 Mar 2018 11:25:08 -0700 Wei Wang <wvw@google.com> wrote:
> > >
> > > > Change VM_MAX_READAHEAD value from the default 128KB to a
configurable
> > > > value. This will allow the readahead window to grow to a maximum
size
> > > > bigger than 128KB during boot, which could benefit to sequential
read
> > > > throughput and thus boot performance.
> > >
> > > You can presently run ioctl(BLKRASET) against the block device?
> > >
> >
> > Yeah we are doing tuning in userland after init. But this is something
we
> > thought could help in very early stage.
> >

> "thought" and "could" are rather weak!  Some impressive performance
> numbers for real-world setups would help such a patch along.

~90ms savings from an Android device compared to setting the window later
in userland.
I was using 'week' words as I agree with Linus's point - it is all about
the storage, so the savings are not universal indeed.
