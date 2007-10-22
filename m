Received: by rv-out-0910.google.com with SMTP id l15so1036513rvb
        for <linux-mm@kvack.org>; Mon, 22 Oct 2007 13:40:14 -0700 (PDT)
Message-ID: <84144f020710221340n6586b6d6web28cea481809b93@mail.gmail.com>
Date: Mon, 22 Oct 2007 23:40:14 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: msync(2) bug(?), returns AOP_WRITEPAGE_ACTIVATE to userland
In-Reply-To: <Pine.LNX.4.64.0710222042500.23513@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <200710142232.l9EMW8kK029572@agora.fsl.cs.sunysb.edu>
	 <Pine.LNX.4.64.0710222042500.23513@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Erez Zadok <ezk@cs.sunysb.edu>, Ryan Finnie <ryan@finnie.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, cjwatson@ubuntu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Hugh,

On 10/22/07, Hugh Dickins <hugh@veritas.com> wrote:
> I don't disagree with your unionfs_writepages patch, Pekka, but I think
> it should be viewed as an optimization (don't waste time trying to write
> a group of pages when we know that nothing will be done) rather than as
> essential.

Ok, so tmpfs needs your fix still.

On 10/22/07, Hugh Dickins <hugh@veritas.com> wrote:
> > So now I wonder if we still need the patch to prevent AOP_WRITEPAGE_ACTIVATE
> > from being returned to userland.  I guess we still need it, b/c even with
> > your patch, generic_writepages() can return AOP_WRITEPAGE_ACTIVATE back to
> > the VFS and we need to ensure that doesn't "leak" outside the kernel.
>
> Can it now?  Current git has a patch from Andrew which bears a striking
> resemblance to that from Pekka, stopping the leak from write_cache_pages.

I don't think it can, it looks ok now.

                             Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
