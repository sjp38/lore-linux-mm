Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9119D6B004F
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 10:33:24 -0400 (EDT)
Date: Tue, 16 Jun 2009 10:34:24 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 0/10] Fix page_mkwrite() for blocksize < pagesize
	(version 3)
Message-ID: <20090616143424.GA22002@infradead.org>
References: <1245088797-29533-1-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1245088797-29533-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Mon, Jun 15, 2009 at 07:59:47PM +0200, Jan Kara wrote:
> 
> patches below are an attempt to solve problems filesystems have with
> page_mkwrite() when blocksize < pagesize (see the changelog of the second patch
> for details).

It would be useful if you had a test case reproducing these issues,
so that I can verify how well your patches work in various scenarios.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
