Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8CFD86B0055
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 13:43:01 -0400 (EDT)
Date: Tue, 30 Jun 2009 13:44:19 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 0/10] Fix page_mkwrite() for blocksize < pagesize
	(version 3)
Message-ID: <20090630174419.GA15102@infradead.org>
References: <1245088797-29533-1-git-send-email-jack@suse.cz> <20090616143424.GA22002@infradead.org> <20090616144217.GA18063@duck.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090616144217.GA18063@duck.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: Christoph Hellwig <hch@infradead.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Tue, Jun 16, 2009 at 04:42:17PM +0200, Jan Kara wrote:
>   Good point, I should have mentioned in the changelog: fsx-linux is able
> to trigger the problem quite quickly.
>   I have also written a simple program for initial testing of the fix
> (works only for 1K blocksize and 4K pagesize) - it's attached.

I haven't been able to trigger anything with it on either xfs or ext4.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
