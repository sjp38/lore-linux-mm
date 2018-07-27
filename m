Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id C9FF36B0003
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 15:01:26 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id n19-v6so3439437pgv.14
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 12:01:26 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.133])
        by mx.google.com with ESMTPS id p7-v6si3946073plo.284.2018.07.27.12.01.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 27 Jul 2018 12:01:24 -0700 (PDT)
Date: Fri, 27 Jul 2018 12:01:22 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: Making direct reclaim fail when thrashing
Message-ID: <20180727190122.GA3825@bombadil.infradead.org>
References: <20180727162143.26466-1-drake@endlessm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180727162143.26466-1-drake@endlessm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Drake <drake@endlessm.com>
Cc: mhocko@kernel.org, hannes@cmpxchg.org, linux-mm@kvack.org, linux@endlessm.com, linux-kernel@vger.kernel.org

On Fri, Jul 27, 2018 at 11:21:43AM -0500, Daniel Drake wrote:
> Here I'm experimenting by adding another tag to the page cache radix tree,
> tagging pages that were activated in the refault path.

NAK.  No more tags or you blow up the memory consumption of the radix
tree by 15%.

> And then in get_scan_count I'm checking how many active pages have that
> tag, and also looking at the size of the active and inactive lists.

You'd be better off using a bit in struct page somewhere ...
