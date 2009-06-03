Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 3E9A46B00CD
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 11:38:20 -0400 (EDT)
Date: Wed, 3 Jun 2009 08:38:15 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 04/23] vfs: Introduce infrastructure for revoking a file
Message-ID: <20090603063815.GE27563@wotan.suse.de>
References: <m1oct739xu.fsf@fess.ebiederm.org> <1243893048-17031-4-git-send-email-ebiederm@xmission.com> <20090602071411.GE31556@wotan.suse.de> <m1tz2ykzy5.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <m1tz2ykzy5.fsf@fess.ebiederm.org>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, "Eric W. Biederman" <ebiederm@aristanetworks.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 02, 2009 at 03:56:02PM -0700, Eric W. Biederman wrote:
> Nick Piggin <npiggin@suse.de> writes:
> 
> >> In addition for a complete solution we need:
> >> - A reliable way the file structures that we need to revoke.
> >> - To wait for but not tamper with ongoing file creation and cleanup.
> >> - A guarantee that all with user space controlled duration are removed.
> >> 
> >> The file_hotplug_lock has a very unique implementation necessitated by
> >> the need to have no performance impact on existing code.  Classic locking
> >
> > Well, it isn't no performance impact. Function calls, branches, icache
> > and dcache...
> 
> Practically none.

OK that's different from none. There is obviously overhead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
