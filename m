Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9AA776B0212
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:59:02 -0400 (EDT)
Date: Wed, 17 Mar 2010 17:58:54 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH][RF C/T/D] Unmapped page cache control - via boot parameter
Message-ID: <20100317165854.GC29548@lst.de>
References: <4B9DE635.8030208@redhat.com> <20100315080726.GB18054@balbir.in.ibm.com> <4B9DEF81.6020802@redhat.com> <20100315202353.GJ3840@arachsys.com> <4B9F4CBD.3020805@redhat.com> <20100317152452.GZ31148@arachsys.com> <4BA101C5.9040406@redhat.com> <4BA105FE.2000607@redhat.com> <20100317164752.GA31884@arachsys.com> <4BA1090E.9090502@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BA1090E.9090502@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Chris Webb <chris@arachsys.com>, balbir@linux.vnet.ibm.com, KVM development list <kvm@vger.kernel.org>, Rik van Riel <riel@surriel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, Kevin Wolf <kwolf@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, Mar 17, 2010 at 06:53:34PM +0200, Avi Kivity wrote:
> Meanwhile I looked at the code, and it looks bad.  There is an 
> IO_CMD_FDSYNC, but it isn't tagged, so we have to drain the queue before 
> issuing it.  In any case, qemu doesn't use it as far as I could tell, 
> and even if it did, device-matter doesn't implement the needed 
> ->aio_fsync() operation.

No one implements it, and all surrounding code is dead wood.  It would
require us to do asynchronous pagecache operations, which involve
major surgery of the VM code.  Patches to do this were rejected multiple
times.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
