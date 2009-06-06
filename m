Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5B43F6B004D
	for <linux-mm@kvack.org>; Sat,  6 Jun 2009 04:08:25 -0400 (EDT)
Date: Sat, 6 Jun 2009 09:08:20 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 02/23] vfs: Implement unpoll_file.
Message-ID: <20090606080820.GA16867@ZenIV.linux.org.uk>
References: <m1oct739xu.fsf@fess.ebiederm.org> <1243893048-17031-2-git-send-email-ebiederm@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1243893048-17031-2-git-send-email-ebiederm@xmission.com>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, "Eric W. Biederman" <ebiederm@maxwell.aristanetworks.com>, "Eric W. Biederman" <ebiederm@aristanetworks.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 01, 2009 at 02:50:27PM -0700, Eric W. Biederman wrote:
> From: Eric W. Biederman <ebiederm@maxwell.aristanetworks.com>
> 
> During a revoke operation it is necessary to stop using all state that is managed
> by the underlying file operations implementation.  The poll wait queue is one part
> of that state.

Erm...  Seeing that drivers and filesystems tend to have fsckloads of
other state of their own, why do we treat that separately?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
