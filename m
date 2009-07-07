Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 25A936B005C
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 10:47:35 -0400 (EDT)
Date: Tue, 7 Jul 2009 10:48:42 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [rfc][patch 1/4] fs: new truncate helpers
Message-ID: <20090707144842.GA3762@infradead.org>
References: <20090707144423.GC2714@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090707144423.GC2714@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 07, 2009 at 04:44:23PM +0200, Nick Piggin wrote:
> 
> Introduce new truncate helpers truncate_pagecache and inode_newsize_ok.
> vmtruncate is also consolidated from mm/memory.c and mm/nommu.c and
> into mm/truncate.c.
> 
> Signed-off-by: Nick Piggin <npiggin@suse.de>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
