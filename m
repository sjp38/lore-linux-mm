Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3FE786B7680
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 16:52:21 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id p4so21854961iod.17
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 13:52:21 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 18sor21860248itz.3.2018.12.05.13.52.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Dec 2018 13:52:18 -0800 (PST)
Date: Wed, 5 Dec 2018 13:52:09 -0800
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/4] filemap: kill page_cache_read usage in filemap_fault
Message-ID: <20181205215209.GA13938@cmpxchg.org>
References: <20181130195812.19536-1-josef@toxicpanda.com>
 <20181130195812.19536-3-josef@toxicpanda.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181130195812.19536-3-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: kernel-team@fb.com, linux-kernel@vger.kernel.org, tj@kernel.org, david@fromorbit.com, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, jack@suse.cz

On Fri, Nov 30, 2018 at 02:58:10PM -0500, Josef Bacik wrote:
> If we do not have a page at filemap_fault time we'll do this weird
> forced page_cache_read thing to populate the page, and then drop it
> again and loop around and find it.  This makes for 2 ways we can read a
> page in filemap_fault, and it's not really needed.  Instead add a
> FGP_FOR_MMAP flag so that pagecache_get_page() will return a unlocked
> page that's in pagecache.  Then use the normal page locking and readpage
> logic already in filemap_fault.  This simplifies the no page in page
> cache case significantly.
> 
> Signed-off-by: Josef Bacik <josef@toxicpanda.com>

That's a great simplification. Looks correct to me.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>
