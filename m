Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6B1925F0001
	for <linux-mm@kvack.org>; Sun, 12 Apr 2009 14:56:11 -0400 (EDT)
Date: Sun, 12 Apr 2009 19:56:59 +0100
From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [RFC][PATCH 8/9] vfs: Implement generic revoked file operations
Message-ID: <20090412185659.GE4394@shareable.org>
References: <m1skkf761y.fsf@fess.ebiederm.org> <m1prfj5qxp.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <m1prfj5qxp.fsf@fess.ebiederm.org>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>

> revoked_file_ops return 0 from reads (aka EOF). Tell poll the file is
> always ready for I/O and return -EIO from all other operations.

I think read should return -EIO too.  If a program is reading from a
/proc file (say), and the thing it's reading suddenly disappears, EOF
gives the false impression that it's read to the end of formatted data
from that file and it can process the data as if it's complete, which
is wrong.

-- Jamie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
