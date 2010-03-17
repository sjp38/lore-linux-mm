Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 05EAD6B011A
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:48:06 -0400 (EDT)
Date: Wed, 17 Mar 2010 16:47:53 +0000
From: Chris Webb <chris@arachsys.com>
Subject: Re: [PATCH][RF C/T/D] Unmapped page cache control - via boot
 parameter
Message-ID: <20100317164752.GA31884@arachsys.com>
References: <20100315072214.GA18054@balbir.in.ibm.com>
 <4B9DE635.8030208@redhat.com>
 <20100315080726.GB18054@balbir.in.ibm.com>
 <4B9DEF81.6020802@redhat.com>
 <20100315202353.GJ3840@arachsys.com>
 <4B9F4CBD.3020805@redhat.com>
 <20100317152452.GZ31148@arachsys.com>
 <4BA101C5.9040406@redhat.com>
 <4BA105FE.2000607@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BA105FE.2000607@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: balbir@linux.vnet.ibm.com, KVM development list <kvm@vger.kernel.org>, Rik van Riel <riel@surriel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, Kevin Wolf <kwolf@redhat.com>
List-ID: <linux-mm.kvack.org>

Avi Kivity <avi@redhat.com> writes:

> Chris, can you carry out an experiment?  Write a program that
> pwrite()s a byte to a file at the same location repeatedly, with the
> file opened using O_SYNC.  Measure the write rate, and run blktrace
> on the host to see what the disk (/dev/sda, not the volume) sees.
> Should be a (write, flush, write, flush) per pwrite pattern or
> similar (for writing the data and a journal block, perhaps even
> three writes will be needed).
> 
> Then scale this across multiple guests, measure and trace again.  If
> we're lucky, the flushes will be coalesced, if not, we need to work
> on it.

Sure, sounds like an excellent plan. I don't have a test machine at the
moment as the last host I was using for this has gone into production, but
I'm due to get another one to install later today or first thing tomorrow
which would be ideal for doing this. I'll follow up with the results once I
have them.

Cheers,

Chris.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
