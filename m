Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6A6F96B0003
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 18:57:56 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id 30so2447483wrw.6
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 15:57:56 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h202si3167534wme.236.2018.02.16.15.57.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Feb 2018 15:57:55 -0800 (PST)
Date: Fri, 16 Feb 2018 15:57:52 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] proc/kpageflags: add KPF_WAITERS
Message-Id: <20180216155752.4a17cfd41875911c79807585@linux-foundation.org>
In-Reply-To: <151834540184.176427.12174649162560874101.stgit@buzz>
References: <151834540184.176427.12174649162560874101.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Nicholas Piggin <npiggin@gmail.com>

On Sun, 11 Feb 2018 13:36:41 +0300 Konstantin Khlebnikov <khlebnikov@yandex-team.ru> wrote:

> KPF_WAITERS indicates tasks are waiting for a page lock or writeback.
> This might be false-positive, in this case next unlock will clear it.

Well, kpageflags is full of potential false-positives.  Or do you think
this flag is especially vulnerable?

In other words, under what circumstances will we have KPF_WAITERS set
when PG_locked and PG-writeback are clear?

> This looks like worth information not only for kernel hacking.

Why?  What are the use-cases, in detail?  How are we to justify this
modification?

> In tool page-types in non-raw mode treat KPF_WAITERS without
> KPF_LOCKED and KPF_WRITEBACK as false-positive and hide it.

>  fs/proc/page.c                         |    1 +
>  include/uapi/linux/kernel-page-flags.h |    1 +
>  tools/vm/page-types.c                  |    7 +++++++

Please update Documentation/vm/pagemap.txt.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
