Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4B0336B025E
	for <linux-mm@kvack.org>; Wed,  7 Sep 2016 20:03:51 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r204so18904620wma.0
        for <linux-mm@kvack.org>; Wed, 07 Sep 2016 17:03:51 -0700 (PDT)
Received: from mail-lf0-x22d.google.com (mail-lf0-x22d.google.com. [2a00:1450:4010:c07::22d])
        by mx.google.com with ESMTPS id s66si248874lfe.350.2016.09.07.09.38.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Sep 2016 09:38:33 -0700 (PDT)
Received: by mail-lf0-x22d.google.com with SMTP id l131so2663657lfl.2
        for <linux-mm@kvack.org>; Wed, 07 Sep 2016 09:38:32 -0700 (PDT)
Date: Wed, 7 Sep 2016 19:38:28 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: mm: kernel BUG in page_add_new_anon_rmap (khugepaged)
Message-ID: <20160907163828.GA20276@node>
References: <CACT4Y+bnSJoKrYpLmHejjxMq1e43zXomAboUxjZ87_2XvrQmGw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+bnSJoKrYpLmHejjxMq1e43zXomAboUxjZ87_2XvrQmGw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Ebru =?iso-8859-1?B?QWthZ/xuZPx6?= <ebru.akagunduz@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Vegard Nossum <vegard.nossum@oracle.com>, Sasha Levin <levinsasha928@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>

On Sat, Sep 03, 2016 at 12:11:21PM +0200, Dmitry Vyukov wrote:
> Hello,
> 
> I've got another BUG in khugepaged while running syzkaller fuzzer:
> 
> kernel BUG at mm/rmap.c:1248!

I think it caused by the same bug as the you've already reported:

http://lkml.kernel.org/r/CACT4Y+Z3gigBvhca9kRJFcjX0G70V_nRhbwKBU+yGoESBDKi9Q@mail.gmail.com

The patch in that thread should address this issue too.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
