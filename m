Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 27FA36B0009
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 04:21:37 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id r129so107961014wmr.0
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 01:21:37 -0800 (PST)
Received: from mail-wm0-x22b.google.com (mail-wm0-x22b.google.com. [2a00:1450:400c:c09::22b])
        by mx.google.com with ESMTPS id w127si21182865wmg.35.2016.02.02.01.21.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Feb 2016 01:21:36 -0800 (PST)
Received: by mail-wm0-x22b.google.com with SMTP id r129so107960493wmr.0
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 01:21:36 -0800 (PST)
Date: Tue, 2 Feb 2016 11:21:33 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: replace vma_lock_anon_vma with
 anon_vma_lock_read/write
Message-ID: <20160202092133.GA817@node.shutemov.name>
References: <145440421918.17103.16454803336779455616.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <145440421918.17103.16454803336779455616.stgit@zurg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>

On Tue, Feb 02, 2016 at 12:10:19PM +0300, Konstantin Khlebnikov wrote:
> Sequence vma_lock_anon_vma() - vma_unlock_anon_vma() isn't safe if
> anon_vma appeared between lock and unlock. We have to check anon_vma
> first or call anon_vma_prepare() to be sure that it's here. There are
> only few users of these legacy helpers. Let's get rid of them.
> 
> This patch fixes anon_vma lock imbalance in validate_mm().
> Write lock isn't required here, read lock is enough.
> 
> And reorders expand_downwards/expand_upwards: security_mmap_addr() and
> wrapping-around check don't have to be under anon vma lock.
> 
> Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Link: https://lkml.kernel.org/r/CACT4Y+Y908EjM2z=706dv4rV6dWtxTLK9nFg9_7DhRMLppBo2g@mail.gmail.com

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
