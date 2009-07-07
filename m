Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D037F6B0055
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 10:52:03 -0400 (EDT)
Date: Tue, 7 Jul 2009 10:53:13 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [rfc][patch 2/4] fs: use new truncate helpers
Message-ID: <20090707145313.GB3762@infradead.org>
References: <20090707144423.GC2714@wotan.suse.de> <20090707144600.GD2714@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090707144600.GD2714@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 07, 2009 at 04:46:00PM +0200, Nick Piggin wrote:
> 
> Update some fs code to make use of new helper functions introduced
> in the previous patch. Should be no significant change in behaviour
> (except CIFS now calls send_sig under i_lock, via inode_newsize_ok).

Looks good to me,


Reviewed-by: Christoph Hellwig <hch@lst.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
