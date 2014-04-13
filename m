Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 7885D6B00B0
	for <linux-mm@kvack.org>; Sun, 13 Apr 2014 18:37:14 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id x10so7356433pdj.20
        for <linux-mm@kvack.org>; Sun, 13 Apr 2014 15:37:11 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id s8si7731470pas.303.2014.04.13.15.37.11
        for <linux-mm@kvack.org>;
        Sun, 13 Apr 2014 15:37:11 -0700 (PDT)
Date: Sun, 13 Apr 2014 15:07:21 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v7 08/22] Replace xip_truncate_page with dax_truncate_page
Message-ID: <20140413190721.GA21460@linux.intel.com>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
 <fd328c564ddc79b41a3a8d754080e6e6e77bbf4f.1395591795.git.matthew.r.wilcox@intel.com>
 <20140408221759.GD26019@quack.suse.cz>
 <20140409092635.GB32103@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140409092635.GB32103@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Apr 09, 2014 at 11:26:35AM +0200, Jan Kara wrote:
>   I thought about this for a while and classical IO, truncation etc. could
> easily work for blocksize < pagesize. And for mmap() you could just use
> pagecache. Not sure if it's worth the complications though. Anyway we
> should decide whether we don't care about blocksize < PAGE_CACHE_SIZE at
> all, or whether we try to make things which can work reasonably easily
> functional. In that case dax_truncate_page() needs some tweaking because it
> currently assumes blocksize == PAGE_CACHE_SIZE.

I think it actually assumes that blocksize <= PAGE_CACHE_SIZE in that
it doesn't contain a loop to iterate over all blocks.  It wouldn't be
hard to fix but I'll just put in a comment noting what needs to be fixed
... I don't think there's going to be a lot of enthusiasm for adding
support for blocksize != PAGE_SIZE / PAGE_CACHE_SIZE.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
