Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B46D46B02A3
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 19:56:00 -0400 (EDT)
Date: Wed, 28 Jul 2010 08:55:43 +0900
Subject: Re: struct backing_dev - purpose and life time rules
From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <20100727140947.GA25106@lst.de>
References: <20100727091459.GA11134@lst.de>
	<20100727133956.GA7347@redhat.com>
	<20100727140947.GA25106@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <20100728085458C.fujita.tomonori@lab.ntt.co.jp>
Sender: owner-linux-mm@kvack.org
To: hch@lst.de
Cc: vgoyal@redhat.com, jaxboe@fusionio.com, peterz@infradead.org, akpm@linux-foundation.org, kay.sievers@vrfy.org, viro@zeniv.linux.org.uk, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Not a comment on the original topic,

On Tue, 27 Jul 2010 16:09:47 +0200
Christoph Hellwig <hch@lst.de> wrote:

> On Tue, Jul 27, 2010 at 09:39:56AM -0400, Vivek Goyal wrote:
> > How can I do it better?
> > 
> > I needed a unique identifier with which user can work in terms of
> > specifying weights to devices and in terms of understanding what stats
> > mean. Device major/minor number looked like a obivious choice.
> > 
> > I was looking for how to determine what is the major/minor number of disk
> > request queue is associated with and I could use bdi to do that.
> 
> The problem is that a queue can be shared between multiple gendisks,

Is anyone still doing this?

I thought that everyone agreed that this was wrong. Such users (like
MTD) were fixed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
