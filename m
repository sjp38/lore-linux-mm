Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f41.google.com (mail-bk0-f41.google.com [209.85.214.41])
	by kanga.kvack.org (Postfix) with ESMTP id DFF626B0035
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 10:46:57 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id v15so269638bkz.28
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 07:46:57 -0800 (PST)
Received: from mail-lb0-x235.google.com (mail-lb0-x235.google.com [2a00:1450:4010:c04::235])
        by mx.google.com with ESMTPS id xw1si332880bkb.102.2013.12.18.07.46.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Dec 2013 07:46:56 -0800 (PST)
Received: by mail-lb0-f181.google.com with SMTP id q8so2099813lbi.26
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 07:46:55 -0800 (PST)
Date: Wed, 18 Dec 2013 19:46:53 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: mm: kernel BUG at include/linux/swapops.h:131!
Message-ID: <20131218154653.GX8167@moon>
References: <52B1C143.8080301@oracle.com>
 <20131218154145.GW8167@moon>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131218154145.GW8167@moon>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, khlebnikov@openvz.org, LKML <linux-kernel@vger.kernel.org>

On Wed, Dec 18, 2013 at 07:41:45PM +0400, Cyrill Gorcunov wrote:
> On Wed, Dec 18, 2013 at 10:37:39AM -0500, Sasha Levin wrote:
> > Hi all,
> > 
> > While fuzzing with trinity inside a KVM tools guest running latest
> > -next kernel, I've stumbled on the following spew.
> > 
> > The code is in zap_pte_range():
> > 
> >                 if (!non_swap_entry(entry))
> >                         rss[MM_SWAPENTS]--;
> >                 else if (is_migration_entry(entry)) {
> >                         struct page *page;
> > 
> >                         page = migration_entry_to_page(entry);	<==== HERE
> > 
> >                         if (PageAnon(page))
> >                                 rss[MM_ANONPAGES]--;
> >                         else
> >                                 rss[MM_FILEPAGES]--;
> 
> This I think is my issue, I'll take a look, thanks Sasha!

Ah, no. I thought it somehow related to dirty tracking, but
it's not, different issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
