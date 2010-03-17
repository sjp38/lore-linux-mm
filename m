Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 51F5F6B0087
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 04:49:20 -0400 (EDT)
Date: Wed, 17 Mar 2010 09:49:11 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH][RF C/T/D] Unmapped page cache control - via boot parameter
Message-ID: <20100317084911.GA9098@lst.de>
References: <20100315072214.GA18054@balbir.in.ibm.com> <4B9DE635.8030208@redhat.com> <20100315080726.GB18054@balbir.in.ibm.com> <4B9DEF81.6020802@redhat.com> <20100315202353.GJ3840@arachsys.com> <4B9F4CBD.3020805@redhat.com> <20100316102637.GA23584@lst.de> <4B9F5F2F.8020501@redhat.com> <20100316104422.GA24258@lst.de> <4B9F66AC.5080400@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B9F66AC.5080400@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>, Chris Webb <chris@arachsys.com>, balbir@linux.vnet.ibm.com, KVM development list <kvm@vger.kernel.org>, Rik van Riel <riel@surriel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kevin Wolf <kwolf@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Mar 16, 2010 at 01:08:28PM +0200, Avi Kivity wrote:
> If the batch size is larger than the virtio queue size, or if there are 
> no flushes at all, then yes the huge write cache gives more opportunity 
> for reordering.  But we're already talking hundreds of requests here.

Yes.  And rememember those don't have to come from the same host.  Also
remember that we rather limit execssive reodering of O_DIRECT requests
in the I/O scheduler because they are "synchronous" type I/O while
we don't do that for pagecache writeback.

And we don't have unlimited virtio queue size, in fact it's quite
limited.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
