Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E6AFD6B00EB
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 18:23:27 -0400 (EDT)
Date: Wed, 26 Aug 2009 00:22:37 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] mm/vmscan: change generic_file_write() comment to do_sync_write()
Message-ID: <20090825222237.GA27240@lst.de>
References: <1251238688-20751-1-git-send-email-macli@brc.ubc.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1251238688-20751-1-git-send-email-macli@brc.ubc.ca>
Sender: owner-linux-mm@kvack.org
To: Vincent Li <macli@brc.ubc.ca>
Cc: linux-mm@kvack.org, Badari Pulavarty <pbadari@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 25, 2009 at 03:18:08PM -0700, Vincent Li wrote:
> Commit 543ade1fc9 (Streamline generic_file_* interfaces and filemap cleanups)
> removed generic_file_write() in filemap. For consistency, change the comment in
> vmscan pageout() to do_sync_write().

I think the right replacement would be __generic_file_aio_write.  But
from a quick glance over the code don't have the slightest idea what it
is referring to.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
