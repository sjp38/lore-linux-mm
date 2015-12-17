Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id A08D94402ED
	for <linux-mm@kvack.org>; Thu, 17 Dec 2015 07:53:57 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id l126so22158147wml.1
        for <linux-mm@kvack.org>; Thu, 17 Dec 2015 04:53:57 -0800 (PST)
Received: from mail-wm0-x22e.google.com (mail-wm0-x22e.google.com. [2a00:1450:400c:c09::22e])
        by mx.google.com with ESMTPS id wx1si17205989wjb.119.2015.12.17.04.53.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Dec 2015 04:53:56 -0800 (PST)
Received: by mail-wm0-x22e.google.com with SMTP id p187so21891805wmp.0
        for <linux-mm@kvack.org>; Thu, 17 Dec 2015 04:53:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CACT4Y+ZCxQgJma5zDuLtHz4RXZGQEgDLwax+McS6iM8BnXsUhA@mail.gmail.com>
References: <CACT4Y+YpcpqhyCiSZYoCzWTVKCmKMBTX-kSdeEBOjoQFQMs77g@mail.gmail.com>
 <20151215194213.GA15672@cmpxchg.org> <CACT4Y+ZCxQgJma5zDuLtHz4RXZGQEgDLwax+McS6iM8BnXsUhA@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 17 Dec 2015 13:53:35 +0100
Message-ID: <CACT4Y+ZSEbP4qpLv+Jyz4sX7gYz6hJvCbLJ36MzcfEgS5D5RWw@mail.gmail.com>
Subject: Re: BUG_ON(!PageLocked(page)) in munlock_vma_page/migrate_pages/__block_write_begin
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Eric B Munson <emunson@akamai.com>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Jeff Vander Stoep <jeffv@google.com>, Alexander Kuleshov <kuleshovmail@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Eric Dumazet <edumazet@google.com>

On Tue, Dec 15, 2015 at 9:08 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Tue, Dec 15, 2015 at 8:42 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
>> Hi Dmitry,
>>
>> On Tue, Dec 15, 2015 at 08:23:34PM +0100, Dmitry Vyukov wrote:
>>>I am seeing lots of similar BUGs in different functions all pointing
>>> to BUG_ON(!PageLocked(page)). I reproduced them on several recent
>>> commits, including stock 6764e5ebd5c62236d082f9ae030674467d0b2779 (Dec
>>> 9) with no changes on top and no KASAN/etc.
>>
>> This should be fixed in newer kernels with this commit:
>> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=dfd01f026058a59a513f8a365b439a0681b803af
>
> Testing with this patch now. Thanks!

It is not happening anymore. So we can consider this as fixed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
