Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id BFF786B0390
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 19:38:25 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 34so2098066pgx.6
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 16:38:25 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c7si5357551pgn.352.2017.03.28.16.38.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 16:38:25 -0700 (PDT)
Date: Tue, 28 Mar 2017 16:38:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mm: BUG in resv_map_release
Message-Id: <20170328163823.3a0445a058670be9254e115c@linux-foundation.org>
In-Reply-To: <CACT4Y+Z-trVe0Oqzs8c+mTG6_iL7hPBBFgOm0p0iQsCz9Q2qiw@mail.gmail.com>
References: <CACT4Y+Z-trVe0Oqzs8c+mTG6_iL7hPBBFgOm0p0iQsCz9Q2qiw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: nyc@holomorphy.com, Michal Hocko <mhocko@suse.com>, Mike Kravetz <mike.kravetz@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>

On Thu, 23 Mar 2017 11:19:38 +0100 Dmitry Vyukov <dvyukov@google.com> wrote:

> Hello,
> 
> I've got the following BUG while running syzkaller fuzzer.
> Note the injected kmalloc failure, most likely it's the root cause.
> 

Yes, probably the logic(?) in region_chg() leaked a
resv->adds_in_progress++, although I'm not sure how.  And afaict that
code can leak the memory at *nrg if the `trg' allocation attempt failed
on the second or later pass around the retry loop.

Blah.  Does someone want to take a look at it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
