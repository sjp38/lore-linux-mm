Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id A1F216B002A
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 17:59:45 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id s8so5275867pgf.16
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 14:59:45 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x32-v6si7152636pld.591.2018.03.16.14.59.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 14:59:44 -0700 (PDT)
Date: Fri, 16 Mar 2018 14:59:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: add config for readahead window
Message-Id: <20180316145942.9e2d353ed10041fbac42e5a3@linux-foundation.org>
In-Reply-To: <CAMFybE7EKyJMmR=Ntn1UX1ZMWJ=32v9G_kYdXh4LhinDv_JO8Q@mail.gmail.com>
References: <20180316182512.118361-1-wvw@google.com>
	<20180316143306.dd98055a170497e9535cc176@linux-foundation.org>
	<CAMFybE7EKyJMmR=Ntn1UX1ZMWJ=32v9G_kYdXh4LhinDv_JO8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.vince.wang@gmail.com>
Cc: Wei Wang <wvw@google.com>, gregkh@linuxfoundation.org, Todd Poynor <toddpoynor@google.com>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>, Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>, Ingo Molnar <mingo@kernel.org>, Sherry Cheung <SCheung@nvidia.com>, Oliver O'Halloran <oohall@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Huang Ying <ying.huang@intel.com>, Dennis Zhou <dennisz@fb.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 16 Mar 2018 21:51:48 +0000 Wei Wang <wei.vince.wang@gmail.com> wrote:

> On Fri, Mar 16, 2018, 14:33 Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > On Fri, 16 Mar 2018 11:25:08 -0700 Wei Wang <wvw@google.com> wrote:
> >
> > > Change VM_MAX_READAHEAD value from the default 128KB to a configurable
> > > value. This will allow the readahead window to grow to a maximum size
> > > bigger than 128KB during boot, which could benefit to sequential read
> > > throughput and thus boot performance.
> >
> > You can presently run ioctl(BLKRASET) against the block device?
> >
> 
> Yeah we are doing tuning in userland after init. But this is something we
> thought could help in very early stage.
> 

"thought" and "could" are rather weak!  Some impressive performance
numbers for real-world setups would help such a patch along.
