Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E1E1B600815
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 10:09:55 -0400 (EDT)
Date: Tue, 27 Jul 2010 16:09:47 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: struct backing_dev - purpose and life time rules
Message-ID: <20100727140947.GA25106@lst.de>
References: <20100727090107.GA9572@lst.de> <20100727091459.GA11134@lst.de> <20100727133956.GA7347@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100727133956.GA7347@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>, jaxboe@fusionio.com, peterz@infradead.org, akpm@linux-foundation.org, kay.sievers@vrfy.org, viro@zeniv.linux.org.uk, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 27, 2010 at 09:39:56AM -0400, Vivek Goyal wrote:
> How can I do it better?
> 
> I needed a unique identifier with which user can work in terms of
> specifying weights to devices and in terms of understanding what stats
> mean. Device major/minor number looked like a obivious choice.
> 
> I was looking for how to determine what is the major/minor number of disk
> request queue is associated with and I could use bdi to do that.

The problem is that a queue can be shared between multiple gendisks,
so dev_t of a gendisk is not a unique identifier.  In addition to that
we even have gendisks that do not even have a block device associated
with them (e.g. for scsi tapes) or request queues that do not have
any gendisks attached to it (e.g. scsi devices without an ULD like
various types of scanners or printers).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
