Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 1F05B6B005A
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 11:56:55 -0400 (EDT)
Date: Wed, 5 Sep 2012 11:56:48 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 01/15 v2] mm: add invalidatepage_range address space
 operation
Message-ID: <20120905155648.GA15985@infradead.org>
References: <1346451711-1931-1-git-send-email-lczerner@redhat.com>
 <1346451711-1931-2-git-send-email-lczerner@redhat.com>
 <20120904164316.6e058cbe.akpm@linux-foundation.org>
 <alpine.LFD.2.00.1209051002310.509@new-host-2>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1209051002310.509@new-host-2>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luk?? Czerner <lczerner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, tytso@mit.edu, hughd@google.com, linux-mm@kvack.org

On Wed, Sep 05, 2012 at 10:36:00AM -0400, Luk?? Czerner wrote:
> However if we would want to keep ->invalidatepage_range() and
> ->invalidatepage() completely separate then we would have to have
> separate truncate_inode_pages_range() and truncate_pagecache_range()
> as well for the separation to actually matter. And IMO this would be
> much worse...

What's the problem with simply changing the ->invalidatepage prototype
to always pass the range and updating all instances for it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
