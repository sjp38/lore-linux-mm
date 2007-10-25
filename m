Date: Thu, 25 Oct 2007 19:23:46 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: msync(2) bug(?), returns AOP_WRITEPAGE_ACTIVATE to userland 
In-Reply-To: <200710251644.l9PGilSK021536@agora.fsl.cs.sunysb.edu>
Message-ID: <Pine.LNX.4.64.0710251913150.21612@blonde.wat.veritas.com>
References: <200710251644.l9PGilSK021536@agora.fsl.cs.sunysb.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Erez Zadok <ezk@cs.sunysb.edu>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Ryan Finnie <ryan@finnie.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, cjwatson@ubuntu.com, linux-mm@kvack.org, neilb@suse.de
List-ID: <linux-mm.kvack.org>

On Thu, 25 Oct 2007, Erez Zadok wrote:
> 
> On a related note, I would just love to get rid of calling the lower
> ->writepage in unionfs b/c I can't even tell if I have a lower page to use
> all the time.  I'd prefer to call vfs_write() if I can, but I'll need a
> struct file, or at least a dentry.

Why do you want to do that?  You gave a good reason why it's easier
for ecryptfs, but I doubt it's robust.  The higher the level you
choose to use, the harder to guarantee it won't deadlock.

Or that's my gut feeling anyway.  It's several years since I've
thought about such issues: just because I came into this knowing
about shmem_writepage, is perhaps not a good reason to choose me
as advisor!

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
