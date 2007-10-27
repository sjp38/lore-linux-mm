Date: Sat, 27 Oct 2007 16:47:33 -0400
Message-Id: <200710272047.l9RKlXAo032686@agora.fsl.cs.sunysb.edu>
From: Erez Zadok <ezk@cs.sunysb.edu>
Subject: Re: msync(2) bug(?), returns AOP_WRITEPAGE_ACTIVATE to userland 
In-reply-to: Your message of "Thu, 25 Oct 2007 19:03:14 BST."
             <Pine.LNX.4.64.0710251743190.9834@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Erez Zadok <ezk@cs.sunysb.edu>, Pekka Enberg <penberg@cs.helsinki.fi>, Ryan Finnie <ryan@finnie.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, cjwatson@ubuntu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

In message <Pine.LNX.4.64.0710251743190.9834@blonde.wat.veritas.com>, Hugh Dickins writes:
> On Mon, 22 Oct 2007, Erez Zadok wrote:
[...]
> > If you've got suggestions how I can handle unionfs_write more cleanly, or
> > comments on the above possibilities, I'd love to hear them.
> 
> For now I think you should pursue the ~(__GFP_FS|__GFP_IO) idea somehow.
> 
> Hugh

Hugh, thanks for the great explanations and suggestions (in multiple
emails).  I'm going to test all of those soon.

Erez.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
