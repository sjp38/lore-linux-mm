Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E59E5600365
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 05:15:10 -0400 (EDT)
Date: Tue, 27 Jul 2010 11:14:59 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: struct backing_dev - purpose and life time rules
Message-ID: <20100727091459.GA11134@lst.de>
References: <20100727090107.GA9572@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100727090107.GA9572@lst.de>
Sender: owner-linux-mm@kvack.org
To: jaxboe@fusionio.com, peterz@infradead.org, akpm@linux-foundation.org, kay.sievers@vrfy.org, viro@zeniv.linux.org.uk, vgoyal@redhat.com
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

In addition to these gem's there's an even worse issue in blk cfq,
introduced in commit

	"blkio: Export disk time and sectors used by a group to user space"

which parses the name inside the backing_dev sysfs device back into a
major / minor number.  Given how obviously stupid this is, and given
the whack a mole blkiocg is I'm tempted to simply break it and see if
anyone cares.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
