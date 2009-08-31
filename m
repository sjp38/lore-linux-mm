Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9B1B86B004D
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 16:36:37 -0400 (EDT)
Date: Mon, 31 Aug 2009 22:36:36 +0200
From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH, RFC] vm: Add an tuning knob for vm.max_writeback_pages
Message-ID: <20090831203636.GD12579@kernel.dk>
References: <1251600858-21294-1-git-send-email-tytso@mit.edu> <20090830165229.GA5189@infradead.org> <20090830181731.GA20822@mit.edu> <20090830222710.GA9938@infradead.org> <20090831030815.GD20822@mit.edu> <20090831102909.GS12579@kernel.dk> <20090831104748.GT12579@kernel.dk> <20090831155441.GB23535@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090831155441.GB23535@mit.edu>
Sender: owner-linux-mm@kvack.org
To: Theodore Tso <tytso@mit.edu>
Cc: Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Ext4 Developers List <linux-ext4@vger.kernel.org>, linux-fsdevel@vger.kernel.org, chris.mason@oracle.com
List-ID: <linux-mm.kvack.org>

On Mon, Aug 31 2009, Theodore Tso wrote:
> At the risk of asking a stupid question, what *is* range_cyclic and
> what is it trying to do?  I've been looking at the code and am I'm
> getting myself very confused about what the code is trying to do and
> what was its original intent.

Range cyclic means that the current writeback in ->writepages() should
start where it left off the last time, non-range cyclic starts off at
->range_start. ->writepages() can use mapping->writeback_index to store
such information.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
