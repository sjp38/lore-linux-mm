Date: Sun, 23 May 2004 05:55:54 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch 21/57] mpol in copy_vma
In-Reply-To: <200405222207.i4MM76r12907@mail.osdl.org>
Message-ID: <Pine.LNX.4.44.0405230550180.15086-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: ak@suse.de, torvalds@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 22 May 2004 akpm@osdl.org wrote:
> 
> From: Hugh Dickins <hugh@veritas.com>
> 
> I think Andi missed the copy_vma I recently added for mremap, and it'll
> need something like below....  (Doesn't look like it'll optimize away when
> it's not needed - rather bloaty.)

It did optimize away - that comment slandered Andi's work - I apologize!

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
