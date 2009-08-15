Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 970AD6B004F
	for <linux-mm@kvack.org>; Sat, 15 Aug 2009 10:51:29 -0400 (EDT)
Date: Sat, 15 Aug 2009 10:51:31 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [rfc][patch 1/3] fs: new truncate sequence
Message-ID: <20090815145131.GA25509@infradead.org>
References: <20090706165438.GQ2714@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090706165438.GQ2714@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick, what's the plan with moving forward on this?  We're badly waiting
for it on the XFS side.  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
