Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 6526F60080D
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 09:40:02 -0400 (EDT)
Date: Tue, 27 Jul 2010 09:39:56 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: struct backing_dev - purpose and life time rules
Message-ID: <20100727133956.GA7347@redhat.com>
References: <20100727090107.GA9572@lst.de>
 <20100727091459.GA11134@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100727091459.GA11134@lst.de>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@lst.de>
Cc: jaxboe@fusionio.com, peterz@infradead.org, akpm@linux-foundation.org, kay.sievers@vrfy.org, viro@zeniv.linux.org.uk, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 27, 2010 at 11:14:59AM +0200, Christoph Hellwig wrote:
> In addition to these gem's there's an even worse issue in blk cfq,
> introduced in commit
> 
> 	"blkio: Export disk time and sectors used by a group to user space"
> 
> which parses the name inside the backing_dev sysfs device back into a
> major / minor number.  Given how obviously stupid this is,

How can I do it better?

I needed a unique identifier with which user can work in terms of
specifying weights to devices and in terms of understanding what stats
mean. Device major/minor number looked like a obivious choice.

I was looking for how to determine what is the major/minor number of disk
request queue is associated with and I could use bdi to do that.

So I was working under the assumption that there is one request queue
associated with one gendisk and I can use major/minor number for that
disk to uniquely identify request queue.

But you seem to be suggesting that there can be multiple gendisk associated
with a single request queue. I am not sure how does that happen but if it
does, that means a single request queue has requests for multiple gendisks
hence for multiple major/minor number pairs?

If yes, then we need to come up with unique naming scheme for request queue
which CFQ can use to export stats to user space through cgroup interface
and also a user can use same name/indentifier to be able to specify per
device/request queue weigths.

> and given
> the whack a mole blkiocg is I'm tempted to simply break it and see if
> anyone cares.

I do care about blkiocg. Why do you think it is a mole? If things are
wrong, guide me how to go about fixing it and I will do that.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
