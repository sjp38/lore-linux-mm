Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 20DF76B0253
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 14:42:36 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id n186so41468484wmn.0
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 11:42:36 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id t6si3413998wmf.88.2015.12.15.11.42.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Dec 2015 11:42:35 -0800 (PST)
Date: Tue, 15 Dec 2015 14:42:13 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: BUG_ON(!PageLocked(page)) in
 munlock_vma_page/migrate_pages/__block_write_begin
Message-ID: <20151215194213.GA15672@cmpxchg.org>
References: <CACT4Y+YpcpqhyCiSZYoCzWTVKCmKMBTX-kSdeEBOjoQFQMs77g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+YpcpqhyCiSZYoCzWTVKCmKMBTX-kSdeEBOjoQFQMs77g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Eric B Munson <emunson@akamai.com>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Jeff Vander Stoep <jeffv@google.com>, Alexander Kuleshov <kuleshovmail@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Eric Dumazet <edumazet@google.com>

Hi Dmitry,

On Tue, Dec 15, 2015 at 08:23:34PM +0100, Dmitry Vyukov wrote:
> I am seeing lots of similar BUGs in different functions all pointing
> to BUG_ON(!PageLocked(page)). I reproduced them on several recent
> commits, including stock 6764e5ebd5c62236d082f9ae030674467d0b2779 (Dec
> 9) with no changes on top and no KASAN/etc.

This should be fixed in newer kernels with this commit: 
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=dfd01f026058a59a513f8a365b439a0681b803af

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
