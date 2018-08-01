Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id F35716B0007
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 14:36:45 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id p5-v6so7046271pfh.11
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 11:36:45 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id m3-v6si8469035plb.68.2018.08.01.11.36.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Aug 2018 11:36:45 -0700 (PDT)
Date: Wed, 1 Aug 2018 11:36:25 -0700
From: "Luck, Tony" <tony.luck@intel.com>
Subject: Re: Linux 4.18-rc7
Message-ID: <20180801183625.GA4412@agluck-desk>
References: <CA+55aFwxwCPZs=h5wy-5PELwfBVuTETm+wuZB5cM2SDoXJi68g@mail.gmail.com>
 <alpine.LSU.2.11.1807301410470.4805@eggly.anvils>
 <CA+55aFx3qR1FW0T3na25NrwLZAvpOdUEUJa879CnaJT2ZPfhkg@mail.gmail.com>
 <alpine.LSU.2.11.1807301940460.5904@eggly.anvils>
 <CALAqxLU3cmu4g+HaB6A7=VhY-hW=d9e68EZ=_4JiwX_BigzjPQ@mail.gmail.com>
 <CAMi1Hd0-2eDod4HiBifKCxY0cUUEW_A-yv7sZ7GRgL0whWQt+w@mail.gmail.com>
 <CA+55aFx=-tHXjv3gv4W=xYwM+VOHJQE5q5VyihkPK7s560x-vQ@mail.gmail.com>
 <20180731170328.ocb5oikwhwtkyzrj@kshutemo-mobl1>
 <20180731174349.GA12944@agluck-desk>
 <CA+55aFxJpJvcYKos-sVTsn9q4wK0-m4up1SXrcqfbXHKxaKxjg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFxJpJvcYKos-sVTsn9q4wK0-m4up1SXrcqfbXHKxaKxjg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Amit Pundir <amit.pundir@linaro.org>, John Stultz <john.stultz@linaro.org>, Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, youling 257 <youling257@gmail.com>, Joel Fernandes <joelaf@google.com>, Colin Cross <ccross@google.com>

On Wed, Aug 01, 2018 at 10:15:05AM -0700, Linus Torvalds wrote:
> Tony, can you please double-check my commit ebad825cdd4e ("ia64: mark
> special ia64 memory areas anonymous") fixes things for  you? I didn't
> even compile it, but it really looks so obvious that I just committed
> it directly. It's not pushed out yet (I'm doing the normal full build
> test because of the ashmem commit first), but it should be out in
> about 20 minutes when my testing has finished.
> 
> I'd like to get this sorted out asap, although at this point I still
> think that I'll have to do an rc8 even though I feel like we may have
> caught everything.

I pulled and got HEAD = 44960f2a7b63e224b1091b3e1d6f60e0cdf4be0c which
includes ebad825cdd4e.

ia64 boots fine with no issues.

Thanks

-Tony
