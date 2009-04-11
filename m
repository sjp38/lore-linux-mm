Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id DA67D5F0001
	for <linux-mm@kvack.org>; Sat, 11 Apr 2009 12:56:07 -0400 (EDT)
Date: Sat, 11 Apr 2009 17:56:51 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC][PATCH 0/9] File descriptor hot-unplug support
Message-ID: <20090411165651.GW26366@ZenIV.linux.org.uk>
References: <m1skkf761y.fsf@fess.ebiederm.org> <20090411155852.GV26366@ZenIV.linux.org.uk> <m1k55ryw2n.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <m1k55ryw2n.fsf@fess.ebiederm.org>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

On Sat, Apr 11, 2009 at 09:49:36AM -0700, Eric W. Biederman wrote:

> The fact that in the common case only one task ever accesses a struct
> file leaves a lot of room for optimization.

I'm not at all sure that it's a good assumption; even leaving aside e.g.
several tasks sharing stdout/stderr, a bunch of datagrams coming out of
several threads over the same socket is quite possible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
