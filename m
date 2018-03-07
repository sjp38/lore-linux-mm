Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0901A6B0003
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 09:19:43 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id 5so1350657wrb.15
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 06:19:42 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t5si1657456wrb.165.2018.03.07.06.19.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 07 Mar 2018 06:19:41 -0800 (PST)
Date: Wed, 7 Mar 2018 15:17:20 +0100
From: David Sterba <dsterba@suse.cz>
Subject: Re: [PATCH v8 06/63] btrfs: Use filemap_range_has_page()
Message-ID: <20180307141720.GA23693@twin.jikos.cz>
Reply-To: dsterba@suse.cz
References: <20180306192413.5499-1-willy@infradead.org>
 <20180306192413.5499-7-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180306192413.5499-7-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org

On Tue, Mar 06, 2018 at 11:23:16AM -0800, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> The current implementation of btrfs_page_exists_in_range() gives the
> wrong answer if the workingset code has stored a shadow entry in the
> page cache.  The filemap_range_has_page() function does not have this
> problem, and it's shared code, so use it instead.

I'm going to merge this patch. btrfs_page_exists_in_range was full of
bugs from the beginning so I'm more than happy to use the shared one.
Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
