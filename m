Date: Wed, 25 Aug 2004 15:05:58 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [Bug 3268] New: Lowmemory exhaustion problem with v2.6.8.1-mm4
    16gb
In-Reply-To: <1093400029.5677.1866.camel@knk>
Message-ID: <Pine.LNX.4.44.0408251448370.4332-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: keith <kmannth@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 24 Aug 2004, keith wrote:
> 
> Ok I created an attachment in the bug for the slab/buddy/mem info.  
> You can watch zone normal get exhausted :)
> http://bugme.osdl.org/show_bug.cgi?id=3268

Thanks.  Yes, your lowmem is full of Slab, and that's entirely
unsurprising since you have CONFIG_DEBUG_PAGEALLOC on: so every
slab object needs a full 4096-byte page to itself (well, there
are some exceptions, but that doesn't change the picture).

That's a _very_ distorting config option, and I think this means that
your report is of no interest in itself - sorry.  But it does raise a
valid question whether it can happen in real, non-debug life - thanks.

I'll do the arithmetic on that when I've more leisure: I expect the
answer to be that it can happen, and I ought to adjust defaulting of
maximum tmpfs inodes.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
