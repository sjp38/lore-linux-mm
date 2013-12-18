Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f53.google.com (mail-bk0-f53.google.com [209.85.214.53])
	by kanga.kvack.org (Postfix) with ESMTP id 8702E6B0035
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 10:41:48 -0500 (EST)
Received: by mail-bk0-f53.google.com with SMTP id na10so262530bkb.40
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 07:41:47 -0800 (PST)
Received: from mail-lb0-x231.google.com (mail-lb0-x231.google.com [2a00:1450:4010:c04::231])
        by mx.google.com with ESMTPS id qz1si330851bkb.69.2013.12.18.07.41.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Dec 2013 07:41:47 -0800 (PST)
Received: by mail-lb0-f177.google.com with SMTP id q8so2083206lbi.8
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 07:41:47 -0800 (PST)
Date: Wed, 18 Dec 2013 19:41:45 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: mm: kernel BUG at include/linux/swapops.h:131!
Message-ID: <20131218154145.GW8167@moon>
References: <52B1C143.8080301@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52B1C143.8080301@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, khlebnikov@openvz.org, LKML <linux-kernel@vger.kernel.org>

On Wed, Dec 18, 2013 at 10:37:39AM -0500, Sasha Levin wrote:
> Hi all,
> 
> While fuzzing with trinity inside a KVM tools guest running latest
> -next kernel, I've stumbled on the following spew.
> 
> The code is in zap_pte_range():
> 
>                 if (!non_swap_entry(entry))
>                         rss[MM_SWAPENTS]--;
>                 else if (is_migration_entry(entry)) {
>                         struct page *page;
> 
>                         page = migration_entry_to_page(entry);	<==== HERE
> 
>                         if (PageAnon(page))
>                                 rss[MM_ANONPAGES]--;
>                         else
>                                 rss[MM_FILEPAGES]--;

This I think is my issue, I'll take a look, thanks Sasha!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
