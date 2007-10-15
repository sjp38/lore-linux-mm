Received: by nz-out-0506.google.com with SMTP id s1so961992nze
        for <linux-mm@kvack.org>; Mon, 15 Oct 2007 04:47:53 -0700 (PDT)
Message-ID: <84144f020710150447o94b1babo8b6e6a647828465f@mail.gmail.com>
Date: Mon, 15 Oct 2007 14:47:52 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: msync(2) bug(?), returns AOP_WRITEPAGE_ACTIVATE to userland
In-Reply-To: <200710142232.l9EMW8kK029572@agora.fsl.cs.sunysb.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <Pine.LNX.4.64.0710142049000.13119@sbz-30.cs.Helsinki.FI>
	 <200710142232.l9EMW8kK029572@agora.fsl.cs.sunysb.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Erez Zadok <ezk@cs.sunysb.edu>
Cc: Hugh Dickins <hugh@veritas.com>, Ryan Finnie <ryan@finnie.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, cjwatson@ubuntu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 10/15/07, Erez Zadok <ezk@cs.sunysb.edu> wrote:
> Pekka, with a small change to your patch (to handle time-based cache
> coherency), your patch worked well and passed all my tests.  Thanks.
>
> So now I wonder if we still need the patch to prevent AOP_WRITEPAGE_ACTIVATE
> from being returned to userland.  I guess we still need it, b/c even with
> your patch, generic_writepages() can return AOP_WRITEPAGE_ACTIVATE back to
> the VFS and we need to ensure that doesn't "leak" outside the kernel.

I wonder whether _not setting_ BDI_CAP_NO_WRITEBACK implies that
->writepage() will never return AOP_WRITEPAGE_ACTIVATE for
!wbc->for_reclaim case which would explain why we haven't hit this bug
before. Hugh, Andrew?

And btw, I think we need to fix ecryptfs too.

                                           Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
