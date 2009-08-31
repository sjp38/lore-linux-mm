Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 36FFA6B004F
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 11:54:36 -0400 (EDT)
Date: Mon, 31 Aug 2009 11:54:41 -0400
From: Theodore Tso <tytso@mit.edu>
Subject: Re: [PATCH, RFC] vm: Add an tuning knob for vm.max_writeback_pages
Message-ID: <20090831155441.GB23535@mit.edu>
References: <1251600858-21294-1-git-send-email-tytso@mit.edu> <20090830165229.GA5189@infradead.org> <20090830181731.GA20822@mit.edu> <20090830222710.GA9938@infradead.org> <20090831030815.GD20822@mit.edu> <20090831102909.GS12579@kernel.dk> <20090831104748.GT12579@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090831104748.GT12579@kernel.dk>
Sender: owner-linux-mm@kvack.org
To: Jens Axboe <jens.axboe@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Ext4 Developers List <linux-ext4@vger.kernel.org>, linux-fsdevel@vger.kernel.org, chris.mason@oracle.com
List-ID: <linux-mm.kvack.org>

At the risk of asking a stupid question, what *is* range_cyclic and
what is it trying to do?  I've been looking at the code and am I'm
getting myself very confused about what the code is trying to do and
what was its original intent.

					- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
