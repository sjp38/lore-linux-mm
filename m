Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 94E176B004D
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 08:45:19 -0400 (EDT)
Date: Thu, 9 Jul 2009 09:01:34 -0400
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [PATCH] bump up nr_to_write in xfs_vm_writepage
Message-ID: <20090709130134.GH18008@think>
References: <20090707193015.7DCD.A69D9226@jp.fujitsu.com> <20090707104440.GB21747@infradead.org> <20090709110342.2386.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090709110342.2386.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Hellwig <hch@infradead.org>, Eric Sandeen <sandeen@redhat.com>, xfs mailing list <xfs@oss.sgi.com>, linux-mm@kvack.org, Olaf Weber <olaf@sgi.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 09, 2009 at 11:04:32AM +0900, KOSAKI Motohiro wrote:
> > On Tue, Jul 07, 2009 at 07:33:04PM +0900, KOSAKI Motohiro wrote:
> > > At least, I agree with Olaf. if you got someone's NAK in past thread,
> > > Could you please tell me its url?
> > 
> > The previous thread was simply dead-ended and nothing happened.
> > 
> 
> Can you remember this thread subject? sorry, I haven't remember it.

This is the original thread, it did lead to a few different patches
going in, but the nr_to_write change wasn't one of them.

http://kerneltrap.org/mailarchive/linux-kernel/2008/10/1/3472704/thread

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
