Date: Mon, 1 Sep 2008 20:09:20 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Anonymous memory on machines without swap
In-Reply-To: <g9hb7v$bnr$1@ger.gmane.org>
Message-ID: <Pine.LNX.4.64.0809012001280.19653@blonde.site>
References: <g9hb7v$bnr$1@ger.gmane.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Sitsofe Wheeler <sitsofe@yahoo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 1 Sep 2008, Sitsofe Wheeler wrote:
> 
> Is it worth having the anonymous memory option turned on in kconfig when
> using the kernel on a machine which has no swap/swapfiles? Does it
> improve memory decisions in some secret way (even though there is no
> swap available) or would it just be completely redundant?

Which is the anonymous memory option in kconfig?

There is CONFIG_SWAP, which you might as well turn off if you don't
intend to use swap/swapfiles.  I don't think it makes any difference to
memory decisions in such a case (they should be based on nr_swap_pages
being 0), but it would shrink your kernel a little.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
