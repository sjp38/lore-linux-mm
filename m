Date: Mon, 22 Oct 2007 21:16:17 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: msync(2) bug(?), returns AOP_WRITEPAGE_ACTIVATE to userland
In-Reply-To: <84144f020710150447o94b1babo8b6e6a647828465f@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0710222101420.23513@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0710142049000.13119@sbz-30.cs.Helsinki.FI>
 <200710142232.l9EMW8kK029572@agora.fsl.cs.sunysb.edu>
 <84144f020710150447o94b1babo8b6e6a647828465f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Erez Zadok <ezk@cs.sunysb.edu>, Ryan Finnie <ryan@finnie.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, cjwatson@ubuntu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 15 Oct 2007, Pekka Enberg wrote:
> 
> I wonder whether _not setting_ BDI_CAP_NO_WRITEBACK implies that
> ->writepage() will never return AOP_WRITEPAGE_ACTIVATE for
> !wbc->for_reclaim case which would explain why we haven't hit this bug
> before. Hugh, Andrew?

Only ramdisk and shmem have been returning AOP_WRITEPAGE_ACTIVATE.
Both of those set BDI_CAP_NO_WRITEBACK.  ramdisk never returned it
if !wbc->for_reclaim.  I contend that shmem shouldn't either: it's
a special code to get the LRU rotation right, not useful elsewhere.
Though Documentation/filesystems/vfs.txt does imply wider use.

I think this is where people use the phrase "go figure" ;)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
